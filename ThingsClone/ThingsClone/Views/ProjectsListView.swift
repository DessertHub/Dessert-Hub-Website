//
//  ProjectsListView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct ProjectsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ProjectViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == NO"),
        animation: .default)
    private var activeProjects: FetchedResults<Project>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Area.sortOrder, ascending: true)],
        animation: .default)
    private var areas: FetchedResults<Area>

    @State private var showingAddProject = false
    @State private var showingAddArea = false
    @State private var newProjectTitle = ""
    @State private var newAreaTitle = ""
    @State private var selectedArea: Area?

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: ProjectViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            List {
                // No Area projects
                if !projectsWithoutArea.isEmpty {
                    Section {
                        ForEach(projectsWithoutArea) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                ProjectRow(project: project, viewModel: viewModel)
                            }
                        }
                    }
                }

                // Projects grouped by Area
                ForEach(areas) { area in
                    let areaProjects = projects(for: area)
                    if !areaProjects.isEmpty {
                        Section {
                            ForEach(areaProjects) { project in
                                NavigationLink(destination: ProjectDetailView(project: project)) {
                                    ProjectRow(project: project, viewModel: viewModel)
                                }
                            }
                        } header: {
                            AreaHeader(area: area, projectCount: areaProjects.count)
                        }
                    } else {
                        Section {
                            Text("No projects")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } header: {
                            AreaHeader(area: area, projectCount: 0)
                        }
                    }
                }

                if activeProjects.isEmpty && areas.isEmpty {
                    emptyState
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddProject = true
                        } label: {
                            Label("New Project", systemImage: "folder.badge.plus")
                        }

                        Button {
                            showingAddArea = true
                        } label: {
                            Label("New Area", systemImage: "square.stack.3d.up")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectSheet(viewModel: viewModel, areas: Array(areas))
            }
            .sheet(isPresented: $showingAddArea) {
                AddAreaSheet(viewModel: viewModel)
            }
        }
    }

    private var projectsWithoutArea: [Project] {
        activeProjects.filter { $0.area == nil }
    }

    private func projects(for area: Area) -> [Project] {
        activeProjects.filter { $0.area == area }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text("No Projects")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Tap + to create a project")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

struct ProjectRow: View {
    @ObservedObject var project: Project
    let viewModel: ProjectViewModel

    private var taskCount: Int {
        (project.tasks as? Set<TaskItem>)?.filter { !$0.isCompleted }.count ?? 0
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(project.title ?? "")
                    .font(.system(size: 16, weight: .medium))

                HStack(spacing: 8) {
                    if taskCount > 0 {
                        Text("\(taskCount) to-dos")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if let deadline = project.deadline {
                        Label(formatDate(deadline), systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            if taskCount > 0 {
                Text("\(taskCount)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(minWidth: 24, minHeight: 24)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct AreaHeader: View {
    @ObservedObject var area: Area
    let projectCount: Int

    var body: some View {
        HStack {
            Text(area.title ?? "")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .textCase(.uppercase)

            Spacer()

            if projectCount > 0 {
                Text("\(projectCount)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct AddProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProjectViewModel

    let areas: [Area]

    @State private var title = ""
    @State private var notes = ""
    @State private var selectedArea: Area?
    @State private var deadline: Date?
    @State private var hasDeadline = false

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
                            ForEach(areas, id: \.id) { area in
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
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addProject()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func addProject() {
        viewModel.createProject(
            title: title,
            notes: notes.isEmpty ? nil : notes,
            area: selectedArea,
            deadline: hasDeadline ? deadline : nil
        )
        dismiss()
    }
}

struct AddAreaSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProjectViewModel

    @State private var title = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Area Name", text: $title)
                        .font(.headline)
                }

                Section {
                    Text("Areas help you organize projects by life domains like Work, Personal, Family, etc.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("New Area")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.createArea(title: title)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ProjectsListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
