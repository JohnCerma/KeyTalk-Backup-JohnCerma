//
//  StartAtLogin+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 3/4/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension StartAtLogin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StartAtLogin> {
        return NSFetchRequest<StartAtLogin>(entityName: "StartAtLogin")
    }

    @NSManaged public var hasPermissionBeenShown: Bool
    @NSManaged public var isStartAtLoginEnabled: Bool
    @NSManaged public var loginKey: String?
    @NSManaged public var permissionKey: String?

}
