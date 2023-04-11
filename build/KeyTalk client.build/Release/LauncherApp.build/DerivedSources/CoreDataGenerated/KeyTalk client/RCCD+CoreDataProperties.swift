//
//  RCCD+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 3/4/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension RCCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RCCD> {
        return NSFetchRequest<RCCD>(entityName: "RCCD")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var iniInfo: String?
    @NSManaged public var rccdName: String?

}
