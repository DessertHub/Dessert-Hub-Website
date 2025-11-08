//
//  ChecklistItem+CoreDataProperties.swift
//  ThingsClone
//
//  Created by Claude
//

import Foundation
import CoreData

extension ChecklistItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistItem> {
        return NSFetchRequest<ChecklistItem>(entityName: "ChecklistItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var sortOrder: Int32
    @NSManaged public var task: TaskItem?
}

extension ChecklistItem: Identifiable {

}
