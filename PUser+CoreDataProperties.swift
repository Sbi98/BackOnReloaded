//
//  PUser+CoreDataProperties.swift
//  
//
//  Created by Emmanuel Tesauro on 18/02/2020.
//
//

import Foundation
import CoreData


extension PUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PUser> {
        return NSFetchRequest<PUser>(entityName: "PUser")
    }

    @NSManaged public var name: String?
    @NSManaged public var photo: URL?
    @NSManaged public var surname: String?
    @NSManaged public var email: String?

}
