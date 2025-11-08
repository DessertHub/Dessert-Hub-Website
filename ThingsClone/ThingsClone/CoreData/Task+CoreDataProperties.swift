//
//  Task+CoreDataProperties.swift
//  ThingsClone
//
//  Created by Claude
//

import Foundation
import CoreData

extension TaskItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isCanceled: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var scheduledDate: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var completedAt: Date?
    @NSManaged public var list: String?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var repeatSchedule: String?
    @NSManaged public var thisEvening: Bool
    @NSManaged public var someday: Bool
    @NSManaged public var project: Project?
    @NSManaged public var heading: Heading?
    @NSManaged public var tags: NSSet?
    @NSManaged public var checklistItems: NSSet?
}

// MARK: Generated accessors for tags
extension TaskItem {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}

// MARK: Generated accessors for checklistItems
extension TaskItem {
    @objc(addChecklistItemsObject:)
    @NSManaged public func addToChecklistItems(_ value: ChecklistItem)

    @objc(removeChecklistItemsObject:)
    @NSManaged public func removeFromChecklistItems(_ value: ChecklistItem)

    @objc(addChecklistItems:)
    @NSManaged public func addToChecklistItems(_ values: NSSet)

    @objc(removeChecklistItems:)
    @NSManaged public func removeFromChecklistItems(_ values: NSSet)
}

extension TaskItem: Identifiable {

}
