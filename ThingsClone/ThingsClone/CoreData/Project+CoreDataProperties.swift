//
//  Project+CoreDataProperties.swift
//  ThingsClone
//
//  Created by Claude
//

import Foundation
import CoreData

extension Project {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completedAt: Date?
    @NSManaged public var deadline: Date?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var area: Area?
    @NSManaged public var tasks: NSSet?
    @NSManaged public var headings: NSSet?
    @NSManaged public var tags: NSSet?
}

// MARK: Generated accessors for tasks
extension Project {
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskItem)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskItem)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}

// MARK: Generated accessors for headings
extension Project {
    @objc(addHeadingsObject:)
    @NSManaged public func addToHeadings(_ value: Heading)

    @objc(removeHeadingsObject:)
    @NSManaged public func removeFromHeadings(_ value: Heading)

    @objc(addHeadings:)
    @NSManaged public func addToHeadings(_ values: NSSet)

    @objc(removeHeadings:)
    @NSManaged public func removeFromHeadings(_ values: NSSet)
}

// MARK: Generated accessors for tags
extension Project {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}

extension Project: Identifiable {

}
