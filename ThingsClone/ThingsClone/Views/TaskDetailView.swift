//
//  TaskDetailView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: TaskItem
    @StateObject private var viewModel: TaskViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == NO"),
        animation: .default)
    private var projects: FetchedResults<Project>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)],
        animation: .default)
    private var allTags: FetchedResults<Tag>

    @State private var title: String
    @State private var notes: String
    @State private var hasWhen: Bool
    @State private var hasDeadline: Bool
    @State private var scheduledDate: Date?
    @State private var dueDate: Date?
    @State private var selectedProject: Project?
    @State private var selectedTags: Set<Tag>
    @State private var checklistItems: [ChecklistItemData] = []
    @State private var showingAddChecklist = false
    @State private var newChecklistItem = ""
    @State private var repeatSchedule: String?
    @State private var thisEvening: Bool
    @State private var someday: Bool

    struct ChecklistItemData: Identifiable {
        let id: UUID
        var title: String
        var isCompleted: Bool
    }

    init(task: TaskItem) {
        self.task = task
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: TaskViewModel(context: context))

        _title = State(initialValue: task.title ?? "")
        _notes = State(initialValue: task.notes ?? "")
        _scheduledDate = State(initialValue: task.scheduledDate)
        _dueDate = State(initialValue: task.dueDate)
        _hasWhen = State(initialValue: task.scheduledDate != nil)
        _hasDeadline = State(initialValue: task.dueDate != nil)
        _selectedProject = State(initialValue: task.project)
        _repeatSchedule = State(initialValue: task.repeatSchedule)
        _thisEvening = State(initialValue: task.thisEvening)
        _someday = State(initialValue: task.someday)

        // Initialize tags
        if let taskTags = task.tags as? Set<Tag> {
            _selectedTags = State(initialValue: taskTags)
        } else {
            _selectedTags = State(initialValue: [])
        }

        // Initialize checklist
        if let items = task.checklistItems as? Set<ChecklistItem> {
            _checklistItems = State(initialValue: items.sorted { $0.sortOrder < $1.sortOrder }.map {
                ChecklistItemData(
                    id: $0.id ?? UUID(),
                    title: $0.title ?? "",
                    isCompleted: $0.isCompleted
                )
            })
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // Title
                Section {
                    TextField("To-Do", text: $title)
                        .font(.headline)
                }

                // Notes
                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .font(.body)
                } header: {
                    Text("Notes")
                }

                // Checklist
                Section {
                    ForEach($checklistItems) { $item in
                        HStack {
                            Button(action: {
                                item.isCompleted.toggle()
                            }) {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isCompleted ? .green : .gray)
                            }

                            TextField("Checklist item", text: $item.title)
                        }
                    }
                    .onDelete { indexSet in
                        checklistItems.remove(atOffsets: indexSet)
                    }

                    Button(action: {
                        checklistItems.append(ChecklistItemData(
                            id: UUID(),
                            title: "",
                            isCompleted: false
                        ))
                    }) {
                        Label("Add Checklist Item", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Checklist")
                }

                // When (Scheduling)
                Section {
                    Toggle("Schedule", isOn: $hasWhen)

                    if hasWhen {
                        DatePicker(
                            "When",
                            selection: Binding(
                                get: { scheduledDate ?? Date() },
                                set: { scheduledDate = $0 }
                            ),
                            displayedComponents: [.date]
                        )

                        Toggle("This Evening", isOn: $thisEvening)
                    }

                    Toggle("Someday", isOn: $someday)
                        .disabled(hasWhen)
                } header: {
                    Text("When")
                }

                // Deadline
                Section {
                    Toggle("Set Deadline", isOn: $hasDeadline)

                    if hasDeadline {
                        DatePicker(
                            "Deadline",
                            selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ),
                            displayedComponents: [.date]
                        )
                    }
                } header: {
                    Text("Deadline")
                }

                // Project
                if !projects.isEmpty {
                    Section {
                        Picker("Project", selection: $selectedProject) {
                            Text("None").tag(nil as Project?)
                            ForEach(Array(projects), id: \.id) { project in
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.blue)
                                    Text(project.title ?? "")
                                }
                                .tag(project as Project?)
                            }
                        }
                    } header: {
                        Text("Project")
                    }
                }

                // Tags
                if !allTags.isEmpty {
                    Section {
                        ForEach(Array(allTags), id: \.id) { tag in
                            Button(action: {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }) {
                                HStack {
                                    Image(systemName: selectedTags.contains(tag) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedTags.contains(tag) ? .blue : .gray)

                                    if let colorHex = tag.colorHex {
                                        Circle()
                                            .fill(Color(hex: colorHex) ?? .gray)
                                            .frame(width: 12, height: 12)
                                    }

                                    Text(tag.title ?? "")
                                        .foregroundColor(.primary)

                                    Spacer()
                                }
                            }
                        }

                        NavigationLink("Manage Tags") {
                            TagsView()
                        }
                    } header: {
                        Text("Tags")
                    }
                }

                // Repeating
                Section {
                    Picker("Repeat", selection: $repeatSchedule) {
                        Text("Never").tag(nil as String?)
                        Text("Daily").tag("daily" as String?)
                        Text("Weekly").tag("weekly" as String?)
                        Text("Monthly").tag("monthly" as String?)
                        Text("Yearly").tag("yearly" as String?)
                    }
                } header: {
                    Text("Repeat")
                }
            }
            .navigationTitle("Edit To-Do")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveTask()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveTask() {
        task.title = title
        task.notes = notes.isEmpty ? nil : notes
        task.scheduledDate = hasWhen ? scheduledDate : nil
        task.dueDate = hasDeadline ? dueDate : nil
        task.project = selectedProject
        task.repeatSchedule = repeatSchedule
        task.thisEvening = thisEvening
        task.someday = someday

        // Update tags
        if let existingTags = task.tags as? Set<Tag> {
            for tag in existingTags {
                task.removeFromTags(tag)
            }
        }
        for tag in selectedTags {
            task.addToTags(tag)
        }

        // Update checklist
        if let existingItems = task.checklistItems as? Set<ChecklistItem> {
            for item in existingItems {
                viewContext.delete(item)
            }
        }

        for (index, itemData) in checklistItems.enumerated() {
            let item = ChecklistItem(context: viewContext)
            item.id = itemData.id
            item.title = itemData.title
            item.isCompleted = itemData.isCompleted
            item.sortOrder = Int32(index)
            item.task = task
        }

        try? viewContext.save()
    }
}

// Color extension for hex strings
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = TaskItem(context: context)
    task.id = UUID()
    task.title = "Sample Task"
    task.createdAt = Date()
    task.isCompleted = false

    return TaskDetailView(task: task)
        .environment(\.managedObjectContext, context)
}
