//
//  LogbookView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct LogbookView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.completedAt, ascending: false)],
        predicate: NSPredicate(format: "isCompleted == YES"),
        animation: .default)
    private var completedTasks: FetchedResults<TaskItem>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.completedAt, ascending: false)],
        predicate: NSPredicate(format: "isCompleted == YES"),
        animation: .default)
    private var completedProjects: FetchedResults<Project>

    @State private var selectedFilter: LogbookFilter = .all
    @State private var searchText = ""

    private let calendar = Calendar.current

    enum LogbookFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case yesterday = "Yesterday"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(LogbookFilter.allCases, id: \.self) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(UIColor.systemBackground))

                Divider()

                // Completed items list
                List {
                    if filteredItems.tasks.isEmpty && filteredItems.projects.isEmpty {
                        emptyState
                    } else {
                        ForEach(groupedItems, id: \.key) { group in
                            Section {
                                // Date header
                                Text(formatDateHeader(group.key))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .textCase(.uppercase)
                                    .padding(.vertical, 4)

                                // Completed tasks
                                ForEach(group.value.tasks, id: \.id) { task in
                                    CompletedTaskRow(task: task)
                                        .contextMenu {
                                            Button {
                                                uncompleteTask(task)
                                            } label: {
                                                Label("Uncomplete", systemImage: "arrow.uturn.backward")
                                            }

                                            Button(role: .destructive) {
                                                deleteTask(task)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }

                                // Completed projects
                                ForEach(group.value.projects, id: \.id) { project in
                                    CompletedProjectRow(project: project)
                                        .contextMenu {
                                            Button {
                                                uncompleteProject(project)
                                            } label: {
                                                Label("Uncomplete", systemImage: "arrow.uturn.backward")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Logbook")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search completed items")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text("No Completed Items")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Completed tasks and projects appear here")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Helper Properties

    private var filteredItems: (tasks: [TaskItem], projects: [Project]) {
        var tasks = Array(completedTasks)
        var projects = Array(completedProjects)

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .today:
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            tasks = tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return completedAt >= startOfDay && completedAt < endOfDay
            }
            projects = projects.filter { project in
                guard let completedAt = project.completedAt else { return false }
                return completedAt >= startOfDay && completedAt < endOfDay
            }
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
            let startOfDay = calendar.startOfDay(for: yesterday)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            tasks = tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return completedAt >= startOfDay && completedAt < endOfDay
            }
            projects = projects.filter { project in
                guard let completedAt = project.completedAt else { return false }
                return completedAt >= startOfDay && completedAt < endOfDay
            }
        case .thisWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            tasks = tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return completedAt >= startOfWeek
            }
            projects = projects.filter { project in
                guard let completedAt = project.completedAt else { return false }
                return completedAt >= startOfWeek
            }
        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
            tasks = tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return completedAt >= startOfMonth
            }
            projects = projects.filter { project in
                guard let completedAt = project.completedAt else { return false }
                return completedAt >= startOfMonth
            }
        }

        // Apply search
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title?.localizedCaseInsensitiveContains(searchText) ?? false ||
                task.notes?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            projects = projects.filter { project in
                project.title?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }

        return (tasks, projects)
    }

    private var groupedItems: [(key: Date, value: (tasks: [TaskItem], projects: [Project]))] {
        var grouped: [Date: (tasks: [TaskItem], projects: [Project])] = [:]

        for task in filteredItems.tasks {
            guard let completedAt = task.completedAt else { continue }
            let day = calendar.startOfDay(for: completedAt)

            if grouped[day] == nil {
                grouped[day] = ([], [])
            }
            grouped[day]?.tasks.append(task)
        }

        for project in filteredItems.projects {
            guard let completedAt = project.completedAt else { continue }
            let day = calendar.startOfDay(for: completedAt)

            if grouped[day] == nil {
                grouped[day] = ([], [])
            }
            grouped[day]?.projects.append(project)
        }

        return grouped.sorted { $0.key > $1.key }
    }

    // MARK: - Helper Methods

    private func formatDateHeader(_ date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }

    private func uncompleteTask(_ task: TaskItem) {
        task.isCompleted = false
        task.completedAt = nil
        try? viewContext.save()
    }

    private func deleteTask(_ task: TaskItem) {
        viewContext.delete(task)
        try? viewContext.save()
    }

    private func uncompleteProject(_ project: Project) {
        project.isCompleted = false
        project.completedAt = nil
        try? viewContext.save()
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .cornerRadius(16)
        }
    }
}

struct CompletedTaskRow: View {
    @ObservedObject var task: TaskItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .strikethrough()

                if let completedAt = task.completedAt {
                    Text(formatTime(completedAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CompletedProjectRow: View {
    @ObservedObject var project: Project

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)

                    Text(project.title ?? "")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .strikethrough()
                }

                if let completedAt = project.completedAt {
                    Text(formatTime(completedAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    LogbookView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
