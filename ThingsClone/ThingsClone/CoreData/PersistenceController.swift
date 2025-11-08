//
//  PersistenceController.swift
//  ThingsClone
//
//  Created by Claude
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Create sample tasks for preview
        for i in 0..<5 {
            let newTask = TaskItem(context: viewContext)
            newTask.id = UUID()
            newTask.title = "Sample Task \(i + 1)"
            newTask.notes = "This is a sample task"
            newTask.isCompleted = false
            newTask.createdAt = Date()
            newTask.list = "inbox"

            if i == 0 {
                newTask.scheduledDate = Date()
                newTask.list = "today"
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskModel")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
