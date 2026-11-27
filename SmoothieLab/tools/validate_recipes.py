#!/usr/bin/env python3
"""Validate the Smoothie Lab recipe data.

Recomputes every recipe's nutrition from ingredients.json (the same way the app
does), then checks that each recipe really meets the rules for every objective
it is listed under, plus the app-wide health rules.

Usage:  python3 tools/validate_recipes.py          (exit code 1 on any error)
        python3 tools/validate_recipes.py --table  (also print a nutrition table)
"""
import json
import sys
from pathlib import Path

RES = Path(__file__).resolve().parent.parent / "SmoothieLab" / "Resources"

# App-wide health rules (mirrored in Core/Nutrition.swift -> HealthRules).
MAX_ADDED_SUGAR_G = 12
MAX_KCAL = 900
MIN_RECIPES_PER_OBJECTIVE = 4


def load(name):
    with open(RES / name, encoding="utf-8") as f:
        return json.load(f)


def nutrition(recipe, ingredients):
    total = dict(kcal=0.0, protein=0.0, carbs=0.0, fat=0.0, fiber=0.0, sugar=0.0, addedSugar=0.0)
    highlights = set()
    for line in recipe["ingredients"]:
        ing = ingredients[line["id"]]
        factor = line["grams"] / 100.0
        for key in ("kcal", "protein", "carbs", "fat", "fiber", "sugar"):
            total[key] += ing["per100g"][key] * factor
        if ing["isAddedSugar"]:
            total["addedSugar"] += ing["per100g"]["sugar"] * factor
        highlights.update(ing["highlights"])
    s = recipe.get("servings", 1)
    total = {k: v / s for k, v in total.items()}
    total["netCarbs"] = max(0.0, total["carbs"] - total["fiber"])
    total["proteinPercent"] = total["protein"] * 4 / total["kcal"] * 100 if total["kcal"] else 0
    return total, highlights


def failures(rules, n, highlights):
    """Return a list of human-readable reasons the rules are not met (mirrors ObjectiveRules.failures)."""
    out = []
    checks = [
        ("minKcal", "kcal", ">="), ("maxKcal", "kcal", "<="),
        ("minProtein", "protein", ">="), ("maxProtein", "protein", "<="),
        ("minProteinPercent", "proteinPercent", ">="),
        ("minCarbs", "carbs", ">="), ("maxCarbs", "carbs", "<="),
        ("maxNetCarbs", "netCarbs", "<="),
        ("maxFat", "fat", "<="),
        ("minFiber", "fiber", ">="), ("maxFiber", "fiber", "<="),
    ]
    for rule, key, op in checks:
        if rule in rules:
            # Compare rounded values: the app displays whole numbers.
            value = round(n[key])
            limit = rules[rule]
            ok = value >= limit if op == ">=" else value <= limit
            if not ok:
                out.append(f"{key} {value} not {op} {limit}")
    need = rules.get("requiresAnyHighlight")
    if need and not highlights.intersection(need):
        out.append(f"needs one of {need}")
    return out


def main():
    ingredients = {i["id"]: i for i in load("ingredients.json")}
    objectives = {o["id"]: o for o in load("objectives.json")}
    recipes = load("recipes.json")
    errors, ids = [], set()
    per_objective = {k: 0 for k in objectives}
    with_supplement = 0

    for r in recipes:
        rid = r["id"]
        if rid in ids:
            errors.append(f"{rid}: duplicate id")
        ids.add(rid)
        missing = [l["id"] for l in r["ingredients"] if l["id"] not in ingredients]
        if missing:
            errors.append(f"{rid}: unknown ingredients {missing}")
            continue
        for key in ("name", "tagline", "flavor", "steps", "whyItWorks", "objectives"):
            if not r.get(key):
                errors.append(f"{rid}: missing {key}")
        kinds = [ingredients[l["id"]]["kind"] for l in r["ingredients"]]
        if "supplement" in kinds:
            with_supplement += 1
        whole_g = sum(l["grams"] for l in r["ingredients"] if ingredients[l["id"]]["kind"] == "wholeFood")
        supp_g = sum(l["grams"] for l in r["ingredients"] if ingredients[l["id"]]["kind"] == "supplement")
        if supp_g > whole_g:
            errors.append(f"{rid}: more supplement than whole food by weight")

        n, hl = nutrition(r, ingredients)
        if n["addedSugar"] > MAX_ADDED_SUGAR_G:
            errors.append(f"{rid}: added sugar {n['addedSugar']:.1f} g > {MAX_ADDED_SUGAR_G}")
        if n["kcal"] > MAX_KCAL:
            errors.append(f"{rid}: {n['kcal']:.0f} kcal > {MAX_KCAL}")
        for oid in r["objectives"]:
            if oid not in objectives:
                errors.append(f"{rid}: unknown objective {oid}")
                continue
            per_objective[oid] += 1
            why = failures(objectives[oid]["rules"], n, hl)
            if why:
                errors.append(f"{rid}: tagged {oid} but " + "; ".join(why))
        extra = [o for o in objectives if o not in r["objectives"] and not failures(objectives[o]["rules"], n, hl)]
        if "--table" in sys.argv:
            print(f"{rid:28} {n['kcal']:4.0f} kcal P{n['protein']:5.1f} C{n['carbs']:5.1f} F{n['fat']:5.1f} "
                  f"Fb{n['fiber']:4.1f} net{n['netCarbs']:5.1f} P%{n['proteinPercent']:3.0f} "
                  f"tags={','.join(r['objectives'])}" + (f"  (also qualifies: {','.join(extra)})" if extra else ""))

    for oid, count in per_objective.items():
        if count < MIN_RECIPES_PER_OBJECTIVE:
            errors.append(f"objective {oid}: only {count} recipes (need {MIN_RECIPES_PER_OBJECTIVE})")

    print(f"{len(recipes)} recipes, {len(ingredients)} ingredients, "
          f"{with_supplement} recipes use a supplement")
    print("per objective: " + ", ".join(f"{k}={v}" for k, v in per_objective.items()))
    if errors:
        print(f"\n{len(errors)} problem(s):")
        for e in errors:
            print("  - " + e)
        sys.exit(1)
    print("All recipes valid.")


if __name__ == "__main__":
    main()
