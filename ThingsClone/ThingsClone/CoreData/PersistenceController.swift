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

        // Create sample areas
        let personalArea = Area(context: viewContext)
        personalArea.id = UUID()
        personalArea.title = "Personal"
        personalArea.sortOrder = 0

        let workArea = Area(context: viewContext)
        workArea.id = UUID()
        workArea.title = "Work"
        workArea.sortOrder = 1

        // Create sample tags
        let urgentTag = Tag(context: viewContext)
        urgentTag.id = UUID()
        urgentTag.title = "Urgent"
        urgentTag.colorHex = "#FF3B30"
        urgentTag.sortOrder = 0

        let homeTag = Tag(context: viewContext)
        homeTag.id = UUID()
        homeTag.title = "Home"
        homeTag.colorHex = "#34C759"
        homeTag.sortOrder = 1

        // Create sample projects
        let project1 = Project(context: viewContext)
        project1.id = UUID()
        project1.title = "Plan Vacation"
        project1.notes = "Summer trip planning"
        project1.createdAt = Date()
        project1.isCompleted = false
        project1.deadline = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        project1.area = personalArea
        project1.sortOrder = 0

        let project2 = Project(context: viewContext)
        project2.id = UUID()
        project2.title = "Website Redesign"
        project2.notes = "Q1 project"
        project2.createdAt = Date()
        project2.isCompleted = false
        project2.area = workArea
        project2.sortOrder = 1

        // Create sample headings
        let heading1 = Heading(context: viewContext)
        heading1.id = UUID()
        heading1.title = "Research"
        heading1.sortOrder = 0
        heading1.isCollapsed = false
        heading1.project = project1

        // Create sample tasks for Inbox
        for i in 0..<3 {
            let task = TaskItem(context: viewContext)
            task.id = UUID()
            task.title = "Inbox Task \(i + 1)"
            task.notes = "This is a sample inbox task"
            task.isCompleted = false
            task.isCanceled = false
            task.createdAt = Date()
            task.list = "inbox"
            task.sortOrder = Int32(i)

            if i == 0 {
                task.addToTags(urgentTag)
            }
        }

        // Create sample tasks for Today
        for i in 0..<3 {
            let task = TaskItem(context: viewContext)
            task.id = UUID()
            task.title = "Today Task \(i + 1)"
            task.notes = "Scheduled for today"
            task.isCompleted = false
            task.isCanceled = false
            task.createdAt = Date()
            task.list = "today"
            task.scheduledDate = Date()
            task.sortOrder = Int32(i)
        }

        // Create sample tasks in project
        for i in 0..<2 {
            let task = TaskItem(context: viewContext)
            task.id = UUID()
            task.title = "Research destination \(i + 1)"
            task.notes = "Find best places to visit"
            task.isCompleted = false
            task.isCanceled = false
            task.createdAt = Date()
            task.list = "project"
            task.project = project1
            task.heading = heading1
            task.sortOrder = Int32(i)

            // Add a checklist to first task
            if i == 0 {
                let checklistItem1 = ChecklistItem(context: viewContext)
                checklistItem1.id = UUID()
                checklistItem1.title = "Check flights"
                checklistItem1.isCompleted = false
                checklistItem1.sortOrder = 0
                checklistItem1.task = task

                let checklistItem2 = ChecklistItem(context: viewContext)
                checklistItem2.id = UUID()
                checklistItem2.title = "Check hotels"
                checklistItem2.isCompleted = true
                checklistItem2.sortOrder = 1
                checklistItem2.task = task
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
