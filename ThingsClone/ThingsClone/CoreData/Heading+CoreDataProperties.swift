//
//  Heading+CoreDataProperties.swift
//  ThingsClone
//
//  Created by Claude
//

import Foundation
import CoreData

extension Heading {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Heading> {
        return NSFetchRequest<Heading>(entityName: "Heading")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var isCollapsed: Bool
    @NSManaged public var project: Project?
    @NSManaged public var tasks: NSSet?
}

// MARK: Generated accessors for tasks
extension Heading {
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskItem)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskItem)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}

extension Heading: Identifiable {

}
