//
//  InboxView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct InboxView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TaskViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.createdAt, ascending: false)],
        predicate: NSPredicate(format: "list == %@ AND isCompleted == NO", "inbox"),
        animation: .default)
    private var tasks: FetchedResults<TaskItem>

    @State private var showingAddTask = false
    @State private var newTaskTitle = ""

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: TaskViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(tasks) { task in
                        TaskRow(task: task) {
                            viewModel.toggleTaskCompletion(task)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteTask(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                viewModel.toggleTaskCompletion(task)
                            } label: {
                                Label("Complete", systemImage: "checkmark")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Inbox")
                .navigationBarTitleDisplayMode(.large)

                // Quick add button (Things-style)
                VStack {
                    if showingAddTask {
                        HStack {
                            TextField("New To-Do", text: $newTaskTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    addTask()
                                }

                            Button(action: addTask) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .shadow(radius: 2)
                    } else {
                        Button(action: { showingAddTask = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("New To-Do")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }

        viewModel.createTask(title: newTaskTitle, list: "inbox")
        newTaskTitle = ""
        showingAddTask = false
    }
}

#Preview {
    InboxView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
