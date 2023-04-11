//
//  CRLFrequency+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 12/11/18.
//
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
