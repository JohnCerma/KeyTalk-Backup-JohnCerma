//
//  CRLDBHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi on 11/19/18.
//

import Foundation
import CoreData

class CRLDBHandler {
    
    /**
     This method is used to save the CRLFrequency to the database. This is done, so that CRL check is automatically done.
     - Parameter timetoCheck : the time to check for CRL.
     - Parameter frequencySelected: the interval at which CRL needs to be checked.
     */
    class func saveCRLFrequencytoDatabase(timetoCheck: Double, frequencySelected: Double) {
        let context = PersistenceService.context
        //deletes the previous value, inorder to save the latest value.
        deleteValueIfPresent(crlKey: CRL_KEY_DB)
        //creates an user entity.
        let entity = NSEntityDescription.entity(forEntityName: "CRLFrequency", in: context)
        if let _entity = entity {
            //gets the value from the entity, in User Type.
            let newConfig = NSManagedObject(entity: _entity, insertInto: context) as? CRLFrequency
            if var _newConfig = newConfig {
                _newConfig.timeToCheck = timetoCheck
                _newConfig.crlFrequencySelected = frequencySelected
                _newConfig.crlKey = CRL_KEY_DB
            }
        }
        //saves the context of the database after updating the values.
        PersistenceService.saveContext()

    }
    
    /**
     This method is used to delete the crl entry of that which already exists in the database.
     - Parameter crlKey: the CRL key from the database.
     */
    class func deleteValueIfPresent(crlKey : String) {
        let context = PersistenceService.persistentContainer.viewContext

        //creates a fetch request for the user entity
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "CRLFrequency")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an CRLFrequency array.
            guard let result = try context.fetch(fetchReq) as? [CRLFrequency] else {
                print("result was invalid.")
                return
            }
            //iterating the result array.
            for data in result {
                let tempkey = data.crlKey
                if tempkey == crlKey {
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
    class func getCRLFrequencyTime() -> Double? {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates the request to fetch the user entity.
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "CRLFrequency")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [CRLFrequency] else {
                print("invalid result found.")
                return nil
            }
            
            //iterating through the result array.
            for data in result {
                if data.crlKey == CRL_KEY_DB {
                    return data.timeToCheck
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    /**
     This method is used to get the CRL Frequency stored in database.
     - Returns: the time interval at which CRL needs to be checked, in Double.
     */
    class func getCRLFrequency() -> Double? {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates the request to fetch the user entity.
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "CRLFrequency")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [CRLFrequency] else {
                print("invalid result found.")
                return nil
            }
            
            //iterating through the result array.
            for data in result {
                if data.crlKey == CRL_KEY_DB {
                return data.crlFrequencySelected
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    /**
     This method is used to delete all the data of the database.
     All the data will be deleted , and the application will be reset to its default state.
     */
    class func deleteAllData() {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates the request to fetch the user entity
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CRLFrequency")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result of the request, an User array.
            guard let result = try context.fetch(request) as? [CRLFrequency] else {
                print("invalid result found.")
                return
            }
            //iterating the result array.
            for data in result {
                //deletes all the elements of the result array from the database.
                context.delete(data)
            }
            
            //updates the database after deleting all the data.
            PersistenceService.saveContext()
        } catch {
            print("Failed")
        }
    }

    
}
