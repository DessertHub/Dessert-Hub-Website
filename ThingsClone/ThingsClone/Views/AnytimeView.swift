//
//  AnytimeView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct AnytimeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TaskViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.createdAt, ascending: false)],
        predicate: NSPredicate(format: "scheduledDate == nil AND dueDate == nil AND isCompleted == NO AND someday == NO AND project == nil AND list == %@", "inbox"),
        animation: .default)
    private var anytimeTasks: FetchedResults<TaskItem>

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
                    if anytimeTasks.isEmpty {
                        emptyState
                    } else {
                        ForEach(anytimeTasks) { task in
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
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Anytime")
                .navigationBarTitleDisplayMode(.large)

                quickAddButton
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text("No Anytime To-Dos")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Tasks without a date go here")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private var quickAddButton: some View {
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

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        viewModel.createTask(title: newTaskTitle, list: "inbox")
        newTaskTitle = ""
        showingAddTask = false
    }
}

#Preview {
    AnytimeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
