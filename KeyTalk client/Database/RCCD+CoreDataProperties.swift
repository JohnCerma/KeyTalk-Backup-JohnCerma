//
//  RCCD+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 12/11/18.
//
//

import Foundation
import CoreData


extension RCCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RCCD> {
        return NSFetchRequest<RCCD>(entityName: "RCCD")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var iniInfo: String?
    @NSManaged public var rccdName: String?

}
