//
//  User+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 12/11/18.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var rccdname: String?
    @NSManaged public var service: String?
    @NSManaged public var username: String?

}
