//
//  LanguagePreference+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 3/4/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension LanguagePreference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LanguagePreference> {
        return NSFetchRequest<LanguagePreference>(entityName: "LanguagePreference")
    }

    @NSManaged public var languageKey: String?
    @NSManaged public var languageSelected: String?

}
