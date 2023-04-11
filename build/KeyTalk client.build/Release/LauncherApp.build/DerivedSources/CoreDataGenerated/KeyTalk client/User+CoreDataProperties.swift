//
//  User+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 3/4/21.
//
//  This file was automatically generated and should not be edited.
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
