//
//  LanguagePreference+CoreDataProperties.swift
//  
//
//  Created by  IntiMac on 12/04/19.
//
//

import Foundation
import CoreData


extension LanguagePreference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LanguagePreference> {
        return NSFetchRequest<LanguagePreference>(entityName: "LanguagePreference")
    }

    @NSManaged public var languageSelected: String?
    @NSManaged public var languageKey: String?

}
