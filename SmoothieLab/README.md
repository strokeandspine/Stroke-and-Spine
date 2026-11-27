# Smoothie Lab — Healthy Smoothie Recipes (iPhone)

An iPhone app with 48 flavorful, high-protein smoothie recipes organized by goal. Every recipe shows calories, protein, carbs, fat, fiber, net carbs, sugars and added sugar, with the macro split shown as a bar. Recipes are built mostly from whole foods, with protein powders, creatine, electrolytes and vitamins added where they help.

The full recipe list, grouped by goal with nutrition, is in [`RECIPES.md`](RECIPES.md).

## Goals

| Goal | Rule every recipe in it meets (per glass) | Recipes |
|---|---|---:|
| Strength Gain | 35 g+ protein and 30%+ of calories from protein | 16 |
| Weight Gain | 550 kcal+ with 30 g+ protein | 8 |
| Fat Loss | 350 kcal or less, 25 g+ protein, 5 g+ fiber | 16 |
| Low Calorie | 250 kcal or less, 15 g+ protein | 9 |
| High Calorie | 650 kcal+ with 30 g+ protein | 7 |
| Increased Energy | 30 g+ carbs plus natural caffeine or nitrates | 8 |
| Low Carb | 15 g or less net carbs, 20 g+ protein | 9 |
| High Carb | 65 g+ carbs, 15 g or less fat | 5 |
| Pre-Workout | 30 g+ carbs, 10 g or less fat, 8 g or less fiber, 400 kcal or less | 7 |
| Post-Workout | 30 g+ protein, 35 g+ carbs, 15 g or less fat | 12 |
| Intra-Workout | 80–250 kcal, 20 g+ carbs, low fat, fiber and protein, with electrolytes | 5 |

Many recipes fit more than one goal. Rules for every recipe: no more than 12 g of added sugar, no more than 900 kcal, and more whole food than supplement by weight.

## How the numbers work

Nutrition is never typed in by hand. Each recipe lists ingredients by weight, and the app adds up each ingredient's per-100 g values from `ingredients.json` (USDA FoodData Central for whole foods, typical label values for supplements). The same calculation runs in the app, in the unit tests and in `tools/validate_recipes.py`, and each recipe is checked against the rules of every goal it's listed under. If you change an ingredient amount and the recipe no longer qualifies, the validator tells you.

## What's in the app

| Screen | What it does |
|---|---|
| Goals | Today's blend, plus a card for each of the 11 goals. Each goal lists its recipes (sorted by the measure that matters for that goal), a short explanation and tips |
| Recipes | Search by name, flavor or ingredient; filter by goal, vegan, dairy-free, nut-free, no supplements, caffeine-free or no added sugar; sort by protein per calorie, protein, calories, carbs or net carbs |
| Recipe | Calories, macro bar and split, protein per 100 kcal, full nutrition, ingredients split into whole foods and supplements (with grams and calories per ingredient), scale to 1–6 glasses, method, why it works, when to drink it, swaps, nutrient highlights, allergens, share, save |
| Saved | Your favorites, stored on the device |
| Guide | How recipes are built, macros in one minute, what each supplement does and who should check with a doctor, allergen and food safety notes |

A one-time welcome screen explains that recipes are general nutrition information, not medical advice.

## Files

| Path | Contents |
|---|---|
| `SmoothieLab/Resources/recipes.json` | The 48 recipes |
| `SmoothieLab/Resources/ingredients.json` | 72 ingredients (58 whole foods, 14 supplements) with per-100 g nutrition, allergens and highlights |
| `SmoothieLab/Resources/objectives.json` | The 11 goals, their rules, default sort and guidance text |
| `SmoothieLab/Core` | Models, nutrition and rule logic (`Models.swift`), data loading, filters, sort and search (`RecipeStore.swift`), favorites |
| `SmoothieLab/Views` | SwiftUI screens |
| `SmoothieLabTests` | Data and logic tests |
| `tools/validate_recipes.py` | Checks the data without Xcode. Add `--table` to print every recipe's numbers and which other goals it qualifies for |
| `tools/export_recipes_md.py` | Regenerates `RECIPES.md` |

## Build and run (requires a Mac)

1. Install Xcode 15 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
2. From this folder (`SmoothieLab/`) run `xcodegen generate`. This creates `SmoothieLab.xcodeproj`.
3. Open it, choose your team under *Signing & Capabilities*, pick an iPhone simulator, and press **Run** (⌘R).
4. Run tests with **Product → Test** (⌘U).

Requires iOS 17. No account, network access or special permissions.

> The Swift code was written in an environment without Xcode, so it has **not been compiled yet**. Expect to fix a few small compile errors on the first build. The recipe data has been fully checked with `tools/validate_recipes.py`.

## Adding or changing a recipe

1. Edit `recipes.json` (and `ingredients.json` if you need a new ingredient).
2. Run `python3 tools/validate_recipes.py --table`.
3. Run `python3 tools/export_recipes_md.py` to refresh `RECIPES.md`.

## Before release

- Have a registered dietitian review the recipes and the supplement guidance.
- "Smoothie Lab" is a working name; check trademarks and App Store availability before you pick a final name.
- Replace the placeholder app icon.
- Add a privacy policy URL. The app collects no data, so the App Store privacy label is "Data Not Collected".

## Ideas for later

- Personal targets (calories and protein per day) with recipes ranked against them
- Build-your-own smoothie with live macro totals
- Shopping list from saved recipes
- Log smoothies to Apple Health (dietary energy and macros)
- Swap protein powder brand to use your label's exact numbers
