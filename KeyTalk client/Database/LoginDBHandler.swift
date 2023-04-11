//
//  LoginDBHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi on 11/29/18.
//

import Foundation
import CoreData

class LoginDBHandler {
    
    class func saveHasPermissionBeenGivenToDatabase(hasPermissionBeenGiven: Bool) {
        let context = PersistenceService.context
        //creates an user entity.
        let entity = NSEntityDescription.entity(forEntityName: "StartAtLogin", in: context)
        if let _entity = entity {
            //gets the value from the entity, in User Type.
            let newConfig = NSManagedObject(entity: _entity, insertInto: context) as? StartAtLogin
            if var _newConfig = newConfig {
                _newConfig.hasPermissionBeenShown = hasPermissionBeenGiven
                _newConfig.permissionKey = PERMISSION_KEY_DB
            }
        }
        //saves the context of the database after updating the values.
        PersistenceService.saveContext()
        
    }
    

    /**
     This method is used to save the CRLFrequency to the database. This is done, so that CRL check is automatically done.
     - Parameter timetoCheck : the time to check for CRL.
     - Parameter frequencySelected: the interval at which CRL needs to be checked.
     */
    class func saveLoginPreferencetoDatabase(isStartAtLoginEnabled: Bool) {
        let context = PersistenceService.context
        //deletes the previous value, inorder to save the latest value.
        deleteValueIfPresent(loginKey: LOGIN_KEY_DB)
        //creates an user entity.
        let entity = NSEntityDescription.entity(forEntityName: "StartAtLogin", in: context)
        if let _entity = entity {
            //gets the value from the entity, in User Type.
            let newConfig = NSManagedObject(entity: _entity, insertInto: context) as? StartAtLogin
            if var _newConfig = newConfig {
                _newConfig.isStartAtLoginEnabled = isStartAtLoginEnabled
                _newConfig.loginKey = LOGIN_KEY_DB
            }
        }
        //saves the context of the database after updating the values.
        PersistenceService.saveContext()
        
    }
    
    /**
     This method is used to delete the crl entry of that which already exists in the database.
     - Parameter crlKey: the CRL key from the database.
     */
    class func deleteValueIfPresent(loginKey : String) {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates a fetch request for the user entity
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StartAtLogin")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an CRLFrequency array.
            guard let result = try context.fetch(fetchReq) as? [StartAtLogin] else {
                print("result was invalid.")
                return
            }
            //iterating the result array.
            for data in result {
                let tempkey = data.loginKey//data.crlKey
                if tempkey == loginKey {
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
    class func getIsStartAtLoginEnabled() -> Bool? {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates the request to fetch the user entity.
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StartAtLogin")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [StartAtLogin] else {
                print("invalid result found.")
                return nil
            }
            
            //iterating through the result array.
            for data in result {
                if data.loginKey == LOGIN_KEY_DB {
                    return data.isStartAtLoginEnabled
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    class func getHasPermissionBeenTaken() -> Bool {
        let context = PersistenceService.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StartAtLogin")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            guard let result = try context.fetch(fetchRequest) as? [StartAtLogin] else  {
                print("invalid result found.")
                return false
            }
            for data in result {
                if data.permissionKey == PERMISSION_KEY_DB {
                    return data.hasPermissionBeenShown
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return false
    }
    
}
