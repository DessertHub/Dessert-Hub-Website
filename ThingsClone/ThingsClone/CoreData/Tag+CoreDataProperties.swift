//
//  Tag+CoreDataProperties.swift
//  ThingsClone
//
//  Created by Claude
//

import Foundation
import CoreData

extension Tag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var tasks: NSSet?
    @NSManaged public var projects: NSSet?
    @NSManaged public var areas: NSSet?
}

// MARK: Generated accessors for tasks
extension Tag {
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskItem)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskItem)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}

// MARK: Generated accessors for projects
extension Tag {
    @objc(addProjectsObject:)
    @NSManaged public func addToProjects(_ value: Project)

    @objc(removeProjectsObject:)
    @NSManaged public func removeFromProjects(_ value: Project)

    @objc(addProjects:)
    @NSManaged public func addToProjects(_ values: NSSet)

    @objc(removeProjects:)
    @NSManaged public func removeFromProjects(_ values: NSSet)
}

// MARK: Generated accessors for areas
extension Tag {
    @objc(addAreasObject:)
    @NSManaged public func addToAreas(_ value: Area)

    @objc(removeAreasObject:)
    @NSManaged public func removeFromAreas(_ value: Area)

    @objc(addAreas:)
    @NSManaged public func addToAreas(_ values: NSSet)

    @objc(removeAreas:)
    @NSManaged public func removeFromAreas(_ values: NSSet)
}

extension Tag: Identifiable {

}
