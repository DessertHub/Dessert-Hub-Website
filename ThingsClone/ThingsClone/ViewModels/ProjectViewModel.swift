//
//  ProjectViewModel.swift
//  ThingsClone
//
//  Created by Claude
//

import Foundation
import CoreData
import SwiftUI

class ProjectViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func createProject(title: String, notes: String? = nil, area: Area? = nil, deadline: Date? = nil) {
        let newProject = Project(context: viewContext)
        newProject.id = UUID()
        newProject.title = title
        newProject.notes = notes
        newProject.area = area
        newProject.deadline = deadline
        newProject.createdAt = Date()
        newProject.isCompleted = false
        newProject.sortOrder = 0

        saveContext()
    }

    func updateProject(_ project: Project, title: String? = nil, notes: String? = nil, area: Area? = nil, deadline: Date? = nil) {
        if let title = title {
            project.title = title
        }
        if let notes = notes {
            project.notes = notes
        }
        if area != nil {
            project.area = area
        }
        if deadline != nil {
            project.deadline = deadline
        }

        saveContext()
    }

    func toggleProjectCompletion(_ project: Project) {
        project.isCompleted.toggle()
        project.completedAt = project.isCompleted ? Date() : nil

        // Complete all tasks in project
        if project.isCompleted {
            if let tasks = project.tasks as? Set<TaskItem> {
                for task in tasks where !task.isCompleted {
                    task.isCompleted = true
                    task.completedAt = Date()
                }
            }
        }

        saveContext()
    }

    func deleteProject(_ project: Project) {
        viewContext.delete(project)
        saveContext()
    }

    func createHeading(in project: Project, title: String) {
        let heading = Heading(context: viewContext)
        heading.id = UUID()
        heading.title = title
        heading.sortOrder = Int32((project.headings?.count ?? 0))
        heading.isCollapsed = false
        heading.project = project

        saveContext()
    }

    func deleteHeading(_ heading: Heading) {
        // Move tasks to no heading
        if let tasks = heading.tasks as? Set<TaskItem> {
            for task in tasks {
                task.heading = nil
            }
        }
        viewContext.delete(heading)
        saveContext()
    }

    func createArea(title: String) {
        let newArea = Area(context: viewContext)
        newArea.id = UUID()
        newArea.title = title
        newArea.sortOrder = 0

        saveContext()
    }

    func deleteArea(_ area: Area) {
        // Move projects to no area
        if let projects = area.projects as? Set<Project> {
            for project in projects {
                project.area = nil
            }
        }
        viewContext.delete(area)
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
