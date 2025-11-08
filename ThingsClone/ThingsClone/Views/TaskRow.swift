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

    var body: some View {
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

                // Date info
                HStack(spacing: 8) {
                    if let dueDate = task.dueDate {
                        Label(formatDate(dueDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if let scheduledDate = task.scheduledDate {
                        Label(formatDate(scheduledDate), systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
