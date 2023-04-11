//
//  CRLFrequency+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 3/4/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CRLFrequency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CRLFrequency> {
        return NSFetchRequest<CRLFrequency>(entityName: "CRLFrequency")
    }

    @NSManaged public var crlFrequencySelected: Double
    @NSManaged public var crlKey: String?
    @NSManaged public var timeToCheck: Double

}
