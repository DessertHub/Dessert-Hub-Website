//
//  ProjectDetailView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct ProjectDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var project: Project
    @StateObject private var taskViewModel: TaskViewModel
    @StateObject private var projectViewModel: ProjectViewModel

    @State private var showingAddTask = false
    @State private var showingAddHeading = false
    @State private var showingEditProject = false
    @State private var newTaskTitle = ""
    @State private var newHeadingTitle = ""
    @State private var selectedHeading: Heading?

    init(project: Project) {
        self.project = project
        let context = PersistenceController.shared.container.viewContext
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(context: context))
        _projectViewModel = StateObject(wrappedValue: ProjectViewModel(context: context))
    }

    private var tasks: [TaskItem] {
        (project.tasks as? Set<TaskItem>)?.filter { !$0.isCompleted }.sorted { $0.sortOrder < $1.sortOrder } ?? []
    }

    private var headings: [Heading] {
        (project.headings as? Set<Heading>)?.sorted { $0.sortOrder < $1.sortOrder } ?? []
    }

    private var tasksWithoutHeading: [TaskItem] {
        tasks.filter { $0.heading == nil }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                // Project info section
                Section {
                    if let notes = project.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    if let deadline = project.deadline {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.orange)
                            Text("Deadline")
                            Spacer()
                            Text(formatDate(deadline))
                                .foregroundColor(.secondary)
                        }
                    }

                    if let area = project.area {
                        HStack {
                            Image(systemName: "square.stack.3d.up")
                                .foregroundColor(.blue)
                            Text("Area")
                            Spacer()
                            Text(area.title ?? "")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Tasks without heading
                if !tasksWithoutHeading.isEmpty {
                    Section {
                        ForEach(tasksWithoutHeading) { task in
                            TaskRow(task: task) {
                                taskViewModel.toggleTaskCompletion(task)
                            }
                            .contextMenu {
                                if !headings.isEmpty {
                                    Menu("Move to Heading") {
                                        ForEach(headings, id: \.id) { heading in
                                            Button(heading.title ?? "") {
                                                task.heading = heading
                                                try? viewContext.save()
                                            }
                                        }
                                    }
                                }

                                Button(role: .destructive) {
                                    taskViewModel.deleteTask(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                // Headings with tasks
                ForEach(headings) { heading in
                    let headingTasks = tasks(for: heading)

                    Section {
                        if !headingTasks.isEmpty {
                            ForEach(headingTasks) { task in
                                TaskRow(task: task) {
                                    taskViewModel.toggleTaskCompletion(task)
                                }
                                .contextMenu {
                                    Button("Remove from Heading") {
                                        task.heading = nil
                                        try? viewContext.save()
                                    }

                                    Button(role: .destructive) {
                                        taskViewModel.deleteTask(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        } else {
                            Text("No tasks in this heading")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } header: {
                        HeadingHeader(heading: heading, onDelete: {
                            projectViewModel.deleteHeading(heading)
                        })
                    }
                }

                if tasks.isEmpty && headings.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.3))
                            Text("No Tasks Yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Add tasks to get started")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(project.title ?? "Project")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddTask = true
                        } label: {
                            Label("New To-Do", systemImage: "plus.circle")
                        }

                        Button {
                            showingAddHeading = true
                        } label: {
                            Label("New Heading", systemImage: "text.justify")
                        }

                        Divider()

                        Button {
                            showingEditProject = true
                        } label: {
                            Label("Edit Project", systemImage: "pencil")
                        }

                        Button {
                            projectViewModel.toggleProjectCompletion(project)
                        } label: {
                            Label(
                                project.isCompleted ? "Mark as Active" : "Mark as Completed",
                                systemImage: "checkmark.circle"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingEditProject) {
                EditProjectSheet(project: project, viewModel: projectViewModel)
            }

            // Quick add buttons
            quickAddButtons
        }
        .alert("New Heading", isPresented: $showingAddHeading) {
            TextField("Heading Name", text: $newHeadingTitle)
            Button("Cancel", role: .cancel) {
                newHeadingTitle = ""
            }
            Button("Add") {
                addHeading()
            }
        }
    }

    private var quickAddButtons: some View {
        VStack(spacing: 8) {
            if showingAddTask {
                HStack {
                    TextField("New To-Do", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addTask()
                        }

                    if !headings.isEmpty {
                        Menu {
                            Button("No Heading") {
                                selectedHeading = nil
                            }
                            ForEach(headings, id: \.id) { heading in
                                Button(heading.title ?? "") {
                                    selectedHeading = heading
                                }
                            }
                        } label: {
                            Image(systemName: selectedHeading == nil ? "list.bullet" : "list.bullet.indent")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
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

    private func tasks(for heading: Heading) -> [TaskItem] {
        tasks.filter { $0.heading == heading }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }

        let task = TaskItem(context: viewContext)
        task.id = UUID()
        task.title = newTaskTitle
        task.createdAt = Date()
        task.isCompleted = false
        task.isCanceled = false
        task.project = project
        task.heading = selectedHeading
        task.list = "project"
        task.sortOrder = Int32(tasks.count)

        try? viewContext.save()

        newTaskTitle = ""
        selectedHeading = nil
        showingAddTask = false
    }

    private func addHeading() {
        guard !newHeadingTitle.isEmpty else { return }
        projectViewModel.createHeading(in: project, title: newHeadingTitle)
        newHeadingTitle = ""
    }
}

struct HeadingHeader: View {
    @ObservedObject var heading: Heading
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(heading.title ?? "")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .textCase(.uppercase)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct EditProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var project: Project
    @ObservedObject var viewModel: ProjectViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Area.sortOrder, ascending: true)],
        animation: .default)
    private var areas: FetchedResults<Area>

    @State private var title: String
    @State private var notes: String
    @State private var selectedArea: Area?
    @State private var deadline: Date?
    @State private var hasDeadline: Bool

    init(project: Project, viewModel: ProjectViewModel) {
        self.project = project
        self.viewModel = viewModel
        _title = State(initialValue: project.title ?? "")
        _notes = State(initialValue: project.notes ?? "")
        _selectedArea = State(initialValue: project.area)
        _deadline = State(initialValue: project.deadline)
        _hasDeadline = State(initialValue: project.deadline != nil)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Project Name", text: $title)
                        .font(.headline)
                }

                Section("Details") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .font(.body)
                }

                if !areas.isEmpty {
                    Section("Area") {
                        Picker("Area", selection: $selectedArea) {
                            Text("None").tag(nil as Area?)
                            ForEach(Array(areas), id: \.id) { area in
                                Text(area.title ?? "").tag(area as Area?)
                            }
                        }
                    }
                }

                Section("Deadline") {
                    Toggle("Set Deadline", isOn: $hasDeadline)

                    if hasDeadline {
                        DatePicker("Deadline", selection: Binding(
                            get: { deadline ?? Date() },
                            set: { deadline = $0 }
                        ), displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("Edit Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProject()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveProject() {
        viewModel.updateProject(
            project,
            title: title,
            notes: notes.isEmpty ? nil : notes,
            area: selectedArea,
            deadline: hasDeadline ? deadline : nil
        )
        dismiss()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let project = Project(context: context)
    project.id = UUID()
    project.title = "Sample Project"
    project.createdAt = Date()
    project.isCompleted = false

    return NavigationView {
        ProjectDetailView(project: project)
            .environment(\.managedObjectContext, context)
    }
}
