//
//  LanguagePrefrenceDBHandler.swift
//  KeyTalk client
//
//  Created by  IntiMac on 12/04/19.
//  Copyright © 2019 KeyTalk. All rights reserved.
//

import Foundation
import CoreData

class LanguagePrefrenceDBHandler {
    
    /**
     This method is used to save the CRLFrequency to the database. This is done, so that CRL check is automatically done.
     - Parameter timetoCheck : the time to check for CRL.
     - Parameter frequencySelected: the interval at which CRL needs to be checked.
     */
    class func saveLanguagePreferencetoDatabase(languageSelected: String) {
        let context = PersistenceService.context
        //deletes the previous value, inorder to save the latest value.
        deleteValueIfPresent(languageKey: LANGUAGE_KEY_DB)
        //creates an user entity.
        let entity = NSEntityDescription.entity(forEntityName: "LanguagePreference", in: context)
        if let _entity = entity {
            //gets the value from the entity, in User Type.
            let newConfig = NSManagedObject(entity: _entity, insertInto: context) as? LanguagePreference
            if var _newConfig = newConfig {
                _newConfig.languageSelected = languageSelected
                _newConfig.languageKey = LANGUAGE_KEY_DB
            }
        }
        //saves the context of the database after updating the values.
        PersistenceService.saveContext()
        
    }
    
    /**
     This method is used to delete the crl entry of that which already exists in the database.
     - Parameter crlKey: the CRL key from the database.
     */
    class func deleteValueIfPresent(languageKey : String) {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates a fetch request for the user entity
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "LanguagePreference")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an CRLFrequency array.
            guard let result = try context.fetch(fetchReq) as? [LanguagePreference] else {
                print("result was invalid.")
                return
            }
            //iterating the result array.
            for data in result {
                let tempkey = data.languageKey//data.crlKey
                if tempkey == languageKey {
                    //deletes the data for that service from the database.
                    context.delete(data)
                }
            }
            //updates the database context after deleting the data.
            PersistenceService.saveContext()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    /**
     This method is used to get the CRL Frequency Time stored in database.
     - Returns: the next time at which CRL needs to be checked, in Double.
     */
    
    class func getLanguageSelected() -> String? {
        let context = PersistenceService.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LanguagePreference")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            guard let result = try context.fetch(fetchRequest) as? [LanguagePreference] else  {
                print("invalid result found.")
                return "en"
            }
            for data in result {
                if data.languageKey == LANGUAGE_KEY_DB {
                    return data.languageSelected
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
}
