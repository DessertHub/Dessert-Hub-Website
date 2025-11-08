//
//  TaskViewModel.swift
//  ThingsClone
//
//  Created by Claude
//

import Foundation
import CoreData
import SwiftUI

class TaskViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func createTask(title: String, notes: String? = nil, list: String = "inbox", scheduledDate: Date? = nil, dueDate: Date? = nil) {
        let newTask = TaskItem(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.notes = notes
        newTask.list = list
        newTask.isCompleted = false
        newTask.createdAt = Date()
        newTask.scheduledDate = scheduledDate
        newTask.dueDate = dueDate

        saveContext()
    }

    func updateTask(_ task: TaskItem, title: String? = nil, notes: String? = nil, scheduledDate: Date? = nil, dueDate: Date? = nil) {
        if let title = title {
            task.title = title
        }
        if let notes = notes {
            task.notes = notes
        }
        if scheduledDate != nil {
            task.scheduledDate = scheduledDate
        }
        if dueDate != nil {
            task.dueDate = dueDate
        }

        saveContext()
    }

    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil
        saveContext()
    }

    func deleteTask(_ task: TaskItem) {
        viewContext.delete(task)
        saveContext()
    }

    func deleteTasks(at offsets: IndexSet, from tasks: [TaskItem]) {
        offsets.forEach { index in
            let task = tasks[index]
            viewContext.delete(task)
        }
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving context: \(nsError), \(nsError.userInfo)")
        }
    }
}
