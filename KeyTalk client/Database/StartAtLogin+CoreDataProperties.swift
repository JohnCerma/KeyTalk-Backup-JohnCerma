//
//  StartAtLogin+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 12/11/18.
//
//

import Foundation
import CoreData


extension StartAtLogin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StartAtLogin> {
        return NSFetchRequest<StartAtLogin>(entityName: "StartAtLogin")
    }

    @NSManaged public var isStartAtLoginEnabled: Bool
    @NSManaged public var loginKey: String?
    @NSManaged public var languageSelected: String?

}
