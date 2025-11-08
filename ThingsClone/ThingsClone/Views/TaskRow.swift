//
//  TaskRow.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI

struct TaskRow: View {
    @ObservedObject var task: TaskItem
    let onToggle: () -> Void

    @State private var showingDetail = false

    private var checklistProgress: (completed: Int, total: Int)? {
        guard let items = task.checklistItems as? Set<ChecklistItem>, !items.isEmpty else {
            return nil
        }
        let completed = items.filter { $0.isCompleted }.count
        let total = items.count
        return (completed, total)
    }

    private var tags: [Tag] {
        (task.tags as? Set<Tag>)?.sorted { ($0.title ?? "") < ($1.title ?? "") } ?? []
    }

    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 12) {
                // Completion checkbox
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(task.isCompleted ? .blue : .gray.opacity(0.3))
                }
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                        .strikethrough(task.isCompleted)

                    if let notes = task.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }

                    // Metadata row
                    HStack(spacing: 8) {
                        // Checklist progress
                        if let progress = checklistProgress {
                            Label("\(progress.completed)/\(progress.total)", systemImage: "checklist")
                                .font(.caption)
                                .foregroundColor(progress.completed == progress.total ? .green : .blue)
                        }

                        // Due date
                        if let dueDate = task.dueDate {
                            Label(formatDate(dueDate), systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(isOverdue(dueDate) ? .red : .orange)
                        }

                        // Scheduled date
                        if let scheduledDate = task.scheduledDate, task.dueDate == nil {
                            Label(formatDate(scheduledDate), systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }

                        // Repeating
                        if task.repeatSchedule != nil {
                            Image(systemName: "repeat")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }

                        // Project indicator
                        if let project = task.project {
                            Label(project.title ?? "", systemImage: "folder.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .lineLimit(1)
                        }
                    }

                    // Tags
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(tags, id: \.id) { tag in
                                    HStack(spacing: 4) {
                                        if let colorHex = tag.colorHex {
                                            Circle()
                                                .fill(Color(hex: colorHex) ?? .gray)
                                                .frame(width: 8, height: 8)
                                        }
                                        Text(tag.title ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            TaskDetailView(task: task)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    private func isOverdue(_ date: Date) -> Bool {
        return date < Calendar.current.startOfDay(for: Date())
    }
}
