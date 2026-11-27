import SwiftUI
import SwiftData

struct DrugLibraryView: View {
    @Bindable var profile: PatientProfile

    var body: some View {
        List {
            Section {
                Text("There are several kinds of osteoporosis medicine. Some slow bone loss (antiresorptives); others build new bone (anabolics). Your doctor chooses based on your fracture risk, other health conditions and preferences.")
                    .font(.subheadline)
                NavigationLink { TreatmentBasicsView() } label: { Label("Key facts about bone medicines", systemImage: "lightbulb") }
            }
            ForEach(OsteoDrugLibrary.byClass) { group in
                Section {
                    ForEach(group.drugs) { drug in
                        NavigationLink { DrugDetailView(drug: drug, profile: profile) } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(drug.genericName).font(.subheadline.bold())
                                Text(drug.brandNames.joined(separator: ", ")).font(.caption).foregroundStyle(.secondary)
                                Text("\(drug.route.label) · \(drug.frequencies.map(\.label).joined(separator: " or ").lowercased())")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text(group.drugClass.name)
                } footer: {
                    Text(group.drugClass.howItWorks)
                }
            }
            Section {
                Text(OsteoDrugLibrary.contentVersion).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Bone medicines")
    }
}

struct DrugDetailView: View {
    let drug: OsteoDrug
    @Bindable var profile: PatientProfile

    @Query private var plans: [MedicationPlan]
    @State private var adding = false

    private var isTaking: Bool { plans.contains { $0.drugID == drug.id && $0.isActive } }

    var body: some View {
        List {
            Section {
                Text(drug.drugClass.name).font(.subheadline.bold())
                Text(drug.drugClass.howItWorks).font(.subheadline)
                LabeledContent("Brands", value: drug.brandNames.joined(separator: ", "))
                LabeledContent("How it's given", value: drug.route.label)
                Text(drug.usualDose).font(.subheadline)
            }
            if let boxed = drug.boxedWarning {
                Section("Boxed warning") {
                    WarningRow(warning: SafetyWarning(id: "boxed", severity: .caution, message: boxed))
                }
            }
            Section("How to take it") { BulletList(items: drug.howToTake) }
            Section("If you miss a dose") { Text(drug.missedDose).font(.subheadline) }
            Section("Common side effects") { BulletList(items: drug.commonSideEffects) }
            Section("Call your doctor if you have") { BulletList(items: drug.callDoctorIf, tint: .orange) }
            Section("Usually not used if you have") { BulletList(items: drug.notFor) }
            Section("How long it's taken") { Text(drug.howLong).font(.subheadline) }
            if let after = drug.afterStopping {
                Section("Stopping") { Text(after).font(.subheadline) }
            }
            Section {
                if isTaking {
                    Label("In your medicines list", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                } else {
                    Button { adding = true } label: { Label("I take this — track it", systemImage: "plus.circle.fill") }
                }
            } footer: {
                Text("This is a summary of US prescribing information. Always follow your prescriber's instructions and read the medication guide that comes with your medicine.")
            }
        }
        .navigationTitle(drug.genericName)
        .sheet(isPresented: $adding) { AddPlanView(drug: drug) }
    }
}

struct TreatmentBasicsView: View {
    private let facts: [(String, String)] = [
        ("Calcium and vitamin D come first", "Every osteoporosis medicine works best — and some are only safe — when you get enough calcium and vitamin D. Low calcium or vitamin D is corrected before starting bisphosphonates, denosumab or romosozumab."),
        ("See your dentist", "Have a dental check-up before starting a bisphosphonate, denosumab or romosozumab if you can, and keep up regular care. Tell your dentist which bone medicine you take, especially before an extraction or implant."),
        ("Don't be late with denosumab", "Denosumab's effect wears off quickly. Being more than a month late, or stopping without switching to another medicine, can cause rapid bone loss and several spine fractures at once."),
        ("Bone builders need a follow-on", "After teriparatide, abaloparatide or romosozumab, a bisphosphonate or denosumab is started to keep the new bone."),
        ("Breaks are planned, not accidental", "After 3–5 years of a bisphosphonate, some people at lower risk can take a planned break. This doesn't apply to denosumab."),
        ("Rare but important side effects", "Osteonecrosis of the jaw and unusual thigh bone fractures are rare (for most people the benefit of preventing fractures is far greater), but tell your doctor about new thigh, hip or groin pain, or jaw problems."),
        ("Tell every doctor", "Keep your bone medicines on your medication list, including injections and yearly infusions that are easy to forget."),
    ]

    var body: some View {
        List {
            ForEach(facts.indices, id: \.self) { i in
                VStack(alignment: .leading, spacing: 4) {
                    Text(facts[i].0).font(.headline)
                    Text(facts[i].1).font(.subheadline)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Key facts")
    }
}
