import SwiftUI
import SwiftData
import Charts

struct LabsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \LabResult.date) private var results: [LabResult]
    @State private var adding = false

    private var markers: [String] { Array(Set(results.map(\.marker))).sorted() }

    var body: some View {
        NavigationStack {
            List {
                if markers.isEmpty {
                    Text("Add blood work or body measurements to see trends next to what you take.")
                        .foregroundStyle(.secondary)
                }
                ForEach(markers, id: \.self) { m in
                    let rows = results.filter { $0.marker == m }
                    Section(m) {
                        if rows.count > 1 {
                            Chart(rows) {
                                LineMark(x: .value("Date", $0.date), y: .value(m, $0.value))
                                PointMark(x: .value("Date", $0.date), y: .value(m, $0.value))
                            }
                            .foregroundStyle(.teal)
                            .frame(height: 140)
                        }
                        ForEach(rows.reversed()) { r in
                            HStack {
                                Text(r.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("\(r.value.formatted()) \(r.unit)").monospacedDigit()
                            }
                        }
                        .onDelete { idx in idx.map { rows.reversed()[$0] }.forEach(context.delete) }
                    }
                }
            }
            .navigationTitle("Labs")
            .toolbar { Button { adding = true } label: { Label("Add result", systemImage: "plus") } }
            .sheet(isPresented: $adding) { AddLabView() }
        }
    }
}

struct AddLabView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var marker = LabMarkers.common[0]
    @State private var custom = ""
    @State private var value = ""
    @State private var unit = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Picker("Marker", selection: $marker) {
                    ForEach(LabMarkers.common + ["Other"], id: \.self, content: Text.init)
                }
                if marker == "Other" { TextField("Marker name", text: $custom) }
                TextField("Value", text: $value).keyboardType(.decimalPad)
                TextField("Unit (e.g. mg/dL)", text: $unit)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Add result")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let name = marker == "Other" ? custom : marker
                        if let v = Double(value.replacingOccurrences(of: ",", with: ".")) {
                            context.insert(LabResult(marker: name, value: v, unit: unit, date: date))
                        }
                        dismiss()
                    }.disabled(Double(value.replacingOccurrences(of: ",", with: ".")) == nil)
                }
            }
        }
    }
}
