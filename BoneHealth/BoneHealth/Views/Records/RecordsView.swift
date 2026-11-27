import SwiftUI
import SwiftData

struct RecordsView: View {
    @Bindable var profile: PatientProfile

    @Query(sort: \RadiologyReport.date, order: .reverse) private var reports: [RadiologyReport]
    @Query(sort: \VitalReading.date, order: .reverse) private var vitals: [VitalReading]
    @Query(sort: \FractureRecord.date, order: .reverse) private var fractures: [FractureRecord]
    @Query(sort: \MedicalHistoryEntry.title) private var history: [MedicalHistoryEntry]
    @Query(sort: \LabResult.date, order: .reverse) private var labs: [LabResult]

    var body: some View {
        NavigationStack {
            List {
                Section("Imaging") {
                    NavigationLink { RadiologyListView(profile: profile) } label: {
                        row("Radiology reports and DEXA scans", "doc.text.image", detail: reports.first.map { "Latest: \($0.kind.label), \($0.date.shortDate)" } ?? "None yet")
                    }
                    NavigationLink { DexaTrendView(profile: profile) } label: {
                        row("Bone density over time", "chart.line.uptrend.xyaxis", detail: "\(reports.filter { $0.kind == .dexa }.count) DEXA scans")
                    }
                }
                Section("Health") {
                    NavigationLink { VitalsListView(profile: profile) } label: {
                        row("Vitals", "heart.text.square", detail: vitals.first.map { "Latest: \($0.date.shortDate)" } ?? "Blood pressure, pulse, weight and height")
                    }
                    NavigationLink { LabListView() } label: {
                        row("Lab results", "testtube.2", detail: labs.first.map { "Latest: \($0.test.name), \($0.date.shortDate)" } ?? "Vitamin D, calcium, kidney function and more")
                    }
                }
                Section("Medical history") {
                    NavigationLink { MedicalHistoryView(profile: profile) } label: {
                        row("Conditions, surgeries, allergies and other medicines", "list.clipboard", detail: "\(history.count) entr\(history.count == 1 ? "y" : "ies")")
                    }
                    NavigationLink { FractureListView() } label: {
                        row("Broken bones", "bandage", detail: fractures.isEmpty ? "None recorded" : "\(fractures.count) recorded")
                    }
                    NavigationLink { RiskFactorsView(profile: profile) } label: {
                        row("Bone risk factors and FRAX", "exclamationmark.shield", detail: "\(profile.riskFactors.count) selected")
                    }
                }
            }
            .navigationTitle("Records")
        }
    }

    private func row(_ title: String, _ symbol: String, detail: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: symbol)
        }
    }
}
