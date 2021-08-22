//
//  Note+CoreDataProperties.swift
//  CoreDataWithDataPicker
//
//  Created by Abdullah Alnutayfi on 22/08/2021.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var id: UUID?

}

extension Note : Identifiable {

}
