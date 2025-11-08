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
    @NSManaged public var createdAt: Date?
    @NSManaged public var scheduledDate: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var list: String?
    @NSManaged public var tags: String?
    @NSManaged public var completedAt: Date?
}

extension TaskItem: Identifiable {

}
