//
//  SearchView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TaskViewModel

    @State private var searchText = ""
    @State private var selectedScope: SearchScope = .all

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.createdAt, ascending: false)],
        animation: .default)
    private var allTasks: FetchedResults<TaskItem>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        animation: .default)
    private var allProjects: FetchedResults<Project>

    enum SearchScope: String, CaseIterable {
        case all = "All"
        case tasks = "To-Dos"
        case projects = "Projects"
    }

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: TaskViewModel(context: context))
    }

    var filteredTasks: [TaskItem] {
        guard !searchText.isEmpty else { return [] }

        return allTasks.filter { task in
            let titleMatch = task.title?.localizedCaseInsensitiveContains(searchText) ?? false
            let notesMatch = task.notes?.localizedCaseInsensitiveContains(searchText) ?? false
            return titleMatch || notesMatch
        }
    }

    var filteredProjects: [Project] {
        guard !searchText.isEmpty else { return [] }

        return allProjects.filter { project in
            let titleMatch = project.title?.localizedCaseInsensitiveContains(searchText) ?? false
            let notesMatch = project.notes?.localizedCaseInsensitiveContains(searchText) ?? false
            return titleMatch || notesMatch
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding()

                // Scope picker
                Picker("Scope", selection: $selectedScope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                Divider()
                    .padding(.top, 8)

                // Results
                if searchText.isEmpty {
                    emptySearchState
                } else {
                    List {
                        // Tasks section
                        if (selectedScope == .all || selectedScope == .tasks) && !filteredTasks.isEmpty {
                            Section {
                                ForEach(filteredTasks) { task in
                                    TaskRow(task: task) {
                                        viewModel.toggleTaskCompletion(task)
                                    }
                                }
                            } header: {
                                HStack {
                                    Text("To-Dos")
                                    Spacer()
                                    Text("\(filteredTasks.count)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Projects section
                        if (selectedScope == .all || selectedScope == .projects) && !filteredProjects.isEmpty {
                            Section {
                                ForEach(filteredProjects) { project in
                                    NavigationLink(destination: ProjectDetailView(project: project)) {
                                        HStack {
                                            Image(systemName: "folder.fill")
                                                .foregroundColor(.blue)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(project.title ?? "")
                                                    .font(.system(size: 16, weight: .medium))

                                                if let notes = project.notes, !notes.isEmpty {
                                                    Text(notes)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                        .lineLimit(1)
                                                }
                                            }
                                        }
                                    }
                                }
                            } header: {
                                HStack {
                                    Text("Projects")
                                    Spacer()
                                    Text("\(filteredProjects.count)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        if filteredTasks.isEmpty && filteredProjects.isEmpty {
                            Section {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.3))
                                    Text("No Results")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    Text("Try a different search term")
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
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptySearchState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text("Search Everything")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Find tasks and projects")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    SearchView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
