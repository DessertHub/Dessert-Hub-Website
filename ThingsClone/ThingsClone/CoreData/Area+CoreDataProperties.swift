//
//  Area+CoreDataProperties.swift
//  ThingsClone
//
//  Created by Claude
//

import Foundation
import CoreData

extension Area {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Area> {
        return NSFetchRequest<Area>(entityName: "Area")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var projects: NSSet?
    @NSManaged public var tags: NSSet?
}

// MARK: Generated accessors for projects
extension Area {
    @objc(addProjectsObject:)
    @NSManaged public func addToProjects(_ value: Project)

    @objc(removeProjectsObject:)
    @NSManaged public func removeFromProjects(_ value: Project)

    @objc(addProjects:)
    @NSManaged public func addToProjects(_ values: NSSet)

    @objc(removeProjects:)
    @NSManaged public func removeFromProjects(_ values: NSSet)
}

// MARK: Generated accessors for tags
extension Area {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}

extension Area: Identifiable {

}
