//
//  TaskEditView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI

struct TaskEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var task: TaskItem
    @StateObject private var viewModel: TaskViewModel

    @State private var title: String
    @State private var notes: String
    @State private var scheduledDate: Date?
    @State private var dueDate: Date?
    @State private var showingScheduledPicker = false
    @State private var showingDuePicker = false

    init(task: TaskItem) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _notes = State(initialValue: task.notes ?? "")
        _scheduledDate = State(initialValue: task.scheduledDate)
        _dueDate = State(initialValue: task.dueDate)

        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: TaskViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .font(.headline)

                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .font(.body)
                }

                Section("Schedule") {
                    Toggle(isOn: Binding(
                        get: { scheduledDate != nil },
                        set: { newValue in
                            if newValue {
                                scheduledDate = Date()
                            } else {
                                scheduledDate = nil
                            }
                        }
                    )) {
                        Label("Today", systemImage: "star")
                    }

                    if scheduledDate != nil {
                        DatePicker("Scheduled", selection: Binding(
                            get: { scheduledDate ?? Date() },
                            set: { scheduledDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }

                Section("Deadline") {
                    Toggle(isOn: Binding(
                        get: { dueDate != nil },
                        set: { newValue in
                            if newValue {
                                dueDate = Date()
                            } else {
                                dueDate = nil
                            }
                        }
                    )) {
                        Label("Set Due Date", systemImage: "calendar")
                    }

                    if dueDate != nil {
                        DatePicker("Due Date", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("Edit Task")
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
        viewModel.updateTask(task, title: title, notes: notes, scheduledDate: scheduledDate, dueDate: dueDate)
    }
}
