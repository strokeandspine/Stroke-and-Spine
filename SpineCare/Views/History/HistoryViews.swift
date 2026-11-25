import SwiftUI
import SwiftData
import PhotosUI

struct HistoryListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SpineHistoryEntry.date, order: .reverse) private var entries: [SpineHistoryEntry]
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                if entries.isEmpty {
                    ContentUnavailableView {
                        Label("No history yet", systemImage: "list.clipboard")
                    } description: {
                        Text("Add your back surgeries, injections, scans and therapy so you have one record to show any doctor.")
                    } actions: {
                        Button("Add an entry") { showingAdd = true }.buttonStyle(.borderedProminent)
                    }
                }
                ForEach(HistoryKind.allCases) { kind in
                    let items = entries.filter { $0.kind == kind }
                    if !items.isEmpty {
                        Section(kind.label) {
                            ForEach(items) { entry in
                                NavigationLink { HistoryDetailView(entry: entry) } label: {
                                    HistoryRow(entry: entry)
                                }
                            }
                            .onDelete { offsets in
                                for i in offsets { context.delete(items[i]) }
                                try? context.save()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Spine history")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add entry")
                }
            }
            .sheet(isPresented: $showingAdd) { HistoryEditView(entry: nil) }
        }
    }
}

struct HistoryRow: View {
    let entry: SpineHistoryEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.kind.symbol).foregroundStyle(.tint).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.typeName).font(.headline)
                Text([entry.date.shortDate, entry.spinalLevels.joined(separator: ", ")].filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct HistoryDetailView: View {
    @Bindable var entry: SpineHistoryEntry
    @State private var editing = false

    private var info: TreatmentInfo? { SpineHistoryCatalog.info(named: entry.typeName) }
    private var isRecent: Bool {
        (Calendar.current.dateComponents([.day], from: entry.date, to: Date()).day ?? 999) <= 42
    }

    var body: some View {
        List {
            Section {
                detail("Date", entry.date.shortDate)
                detail("Spinal level(s)", entry.spinalLevels.joined(separator: ", "))
                detail("Side", entry.side)
                detail("Doctor / provider", entry.provider)
                detail("Hospital / clinic", entry.facility)
                detail("Implants or hardware", entry.implants)
                if let relief = entry.reliefPercent {
                    detail("Pain relief", "\(relief)%" + (entry.reliefWeeks.map { " for about \($0) weeks" } ?? ""))
                }
                detail("Complications", entry.complications)
                detail("Notes", entry.notes)
            }

            if !entry.attachments.isEmpty {
                Section("Documents and photos") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(entry.attachments) { attachment in
                                if let image = UIImage(data: attachment.imageData) {
                                    Image(uiImage: image).resizable().scaledToFill()
                                        .frame(width: 120, height: 160).clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
            }

            if let info {
                Section("About this treatment") {
                    Text(info.summary)
                }
                if !info.whatToExpect.isEmpty {
                    Section("What to expect") {
                        ForEach(info.whatToExpect, id: \.self) { Text($0) }
                    }
                }
            }

            if entry.kind == .surgery || entry.kind == .procedure {
                Section {
                    ForEach(SpineHistoryCatalog.generalWarningSigns + (info?.callYourDoctorIf ?? []), id: \.self) {
                        Label($0, systemImage: "exclamationmark.triangle").font(.subheadline)
                    }
                } header: {
                    Text(isRecent ? "Call your surgeon or doctor if you have" : "Warning signs after this treatment")
                } footer: {
                    Text(SpineHistoryCatalog.generalDisclaimer)
                }
            }
        }
        .navigationTitle(entry.typeName)
        .toolbar { Button("Edit") { editing = true } }
        .sheet(isPresented: $editing) { HistoryEditView(entry: entry) }
    }

    @ViewBuilder private func detail(_ title: String, _ value: String) -> some View {
        if !value.isEmpty {
            LabeledContent(title, value: value)
        }
    }
}

struct HistoryEditView: View {
    var entry: SpineHistoryEntry?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var kind: HistoryKind = .surgery
    @State private var typeName = ""
    @State private var customType = ""
    @State private var date = Date()
    @State private var levels: [String] = []
    @State private var side = ""
    @State private var provider = ""
    @State private var facility = ""
    @State private var implants = ""
    @State private var complications = ""
    @State private var notes = ""
    @State private var recordRelief = false
    @State private var reliefPercent = 50
    @State private var reliefWeeks = 4
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var newImages: [Data] = []

    private static let otherOption = "Other…"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $kind) {
                        ForEach(HistoryKind.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("Treatment", selection: $typeName) {
                        Text("Choose…").tag("")
                        ForEach(SpineHistoryCatalog.treatments(for: kind)) { Text($0.name).tag($0.name) }
                        Text(Self.otherOption).tag(Self.otherOption)
                    }
                    if typeName == Self.otherOption {
                        TextField("Name of treatment", text: $customType)
                    }
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                }

                if kind != .therapy {
                    Section("Where in the spine") {
                        TagPicker(options: SpineHistoryCatalog.spinalLevels, selection: $levels)
                        Picker("Side", selection: $side) {
                            ForEach(SpineHistoryCatalog.sides, id: \.self) { Text($0.isEmpty ? "Not sure / not applicable" : $0).tag($0) }
                        }
                    }
                }

                Section("Who and where") {
                    TextField("Doctor or provider", text: $provider)
                    TextField("Hospital or clinic", text: $facility)
                    if kind == .surgery {
                        TextField("Implants or hardware (screws, rods, cage, stimulator…)", text: $implants, axis: .vertical)
                    }
                }

                if kind != .imaging {
                    Section("How much did it help?") {
                        Toggle("Record pain relief", isOn: $recordRelief)
                        if recordRelief {
                            Stepper("\(reliefPercent)% relief", value: $reliefPercent, in: 0...100, step: 10)
                            Stepper("Lasted about \(reliefWeeks) week\(reliefWeeks == 1 ? "" : "s")", value: $reliefWeeks, in: 0...520)
                        }
                        TextField("Complications or side effects", text: $complications, axis: .vertical)
                    }
                }

                Section("Notes and documents") {
                    TextField("Notes", text: $notes, axis: .vertical)
                    PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                        Label("Add photos of reports or instructions", systemImage: "doc.viewfinder")
                    }
                    if !newImages.isEmpty {
                        Text("\(newImages.count) new photo\(newImages.count == 1 ? "" : "s") will be attached").font(.caption)
                    }
                }
            }
            .navigationTitle(entry == nil ? "Add to history" : "Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.bold().disabled(resolvedName.isEmpty)
                }
            }
            .onAppear(perform: load)
            .onChange(of: kind) { _, _ in
                if !SpineHistoryCatalog.treatments(for: kind).contains(where: { $0.name == typeName }) && typeName != Self.otherOption {
                    typeName = ""
                }
            }
            .onChange(of: pickerItems) { _, items in
                Task {
                    var loaded: [Data] = []
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self) { loaded.append(data) }
                    }
                    newImages = loaded
                }
            }
        }
    }

    private var resolvedName: String {
        typeName == Self.otherOption ? customType.trimmingCharacters(in: .whitespaces) : typeName
    }

    private func load() {
        guard let e = entry else { return }
        kind = e.kind
        if SpineHistoryCatalog.info(named: e.typeName) != nil {
            typeName = e.typeName
        } else {
            typeName = Self.otherOption
            customType = e.typeName
        }
        date = e.date; levels = e.spinalLevels; side = e.side
        provider = e.provider; facility = e.facility; implants = e.implants
        complications = e.complications; notes = e.notes
        if let r = e.reliefPercent { recordRelief = true; reliefPercent = r }
        if let w = e.reliefWeeks { reliefWeeks = w }
    }

    private func save() {
        let target = entry ?? SpineHistoryEntry(kind: kind, typeName: resolvedName, date: date)
        if entry == nil { context.insert(target) }
        target.kind = kind
        target.typeName = resolvedName
        target.date = date
        target.spinalLevels = levels
        target.side = side
        target.provider = provider
        target.facility = facility
        target.implants = implants
        target.complications = complications
        target.notes = notes
        target.reliefPercent = recordRelief ? reliefPercent : nil
        target.reliefWeeks = recordRelief ? reliefWeeks : nil
        for data in newImages {
            let attachment = HistoryAttachment(imageData: data)
            context.insert(attachment)
            attachment.entry = target
        }
        try? context.save()
        dismiss()
    }
}
