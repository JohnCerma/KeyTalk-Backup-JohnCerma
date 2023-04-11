//
//  UserDetailsHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import CoreData

// For User Handling.
class UserDetailsHandler {
    
    /**
     This method is used to save the username corresponding to a Service which user enters inorder to download the certificate initially. This is done, so that whenever the user selects a service , username textfield will get prepopulated with the last username entered by the user.
     - Parameter rccdname : the rccd file name corresponding to the service.
     - Parameter username: username entered by the user inorder to use the service.
     - Parameter services: service name for which the username is used.
     */
    class func saveUsernameAndServices(rccdname : String ,username: String, services: String) {
        
        let context = PersistenceService.persistentContainer.viewContext
        
        //deletes the previous value, inorder to save the latest value.
        deleteValueIfPresent(rccdFileName: rccdname, service: services)
        
        //creates an user entity.
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
       
        DispatchQueue.main.async {
     
            if let _entity = entity {
            //gets the value from the entity, in User Type.
            let newConfig = NSManagedObject(entity: _entity, insertInto: context) as? User
            if let _newConfig = newConfig {
                //sets the rccdname associated with the service and username
                _newConfig.rccdname = rccdname
                //sets the service field with the services parameter.
                _newConfig.service = services
                //sets the username field with the username parameter.
                _newConfig.username = username
            }
        }
        //saves the context of the database after updating the values.
        PersistenceService.saveContext()
    }
}
    
    /**
     This method is used to delete the user entry of that service which already exists in the database.
     - Parameter service: the service name for which the user entry have to be deleted.
     */
    class func deleteValueIfPresent(rccdFileName : String ,service: String) {
        let context = PersistenceService.persistentContainer.viewContext  // (NSManagedObjectContextConcurrencyType .privateQueueConcurrencyType)
        
        //creates a fetch request for the user entity
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchReq.returnsObjectsAsFaults = false
        
        DispatchQueue.main.async {
        
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [User] else {
                print("result was invalid.")
                return
            }
            //iterating the result array.
            for data in result {
                //gets the service name from the result data.
                let tempService = data.service
                
                //gets rhe rccd name from the result data.
                let tempRCCD = data.rccdname
                
                //if the services and rccd mathches.
                if tempService == service && tempRCCD == rccdFileName {
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
}
    
    
    /**
     This method is used to delete the database entry of that rccd file for which the services and its username already exists in the database.
     - Parameter rccdname: the  name of the rccdFile for which the user entries have to be deleted whose services are associated with this rccd file.
     */
    class func deleteValueIfPresent(rccdname: String) {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates a fetch request for the user entity
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [User] else {
                print("result was invalid.")
                return
            }
            //iterating the result array.
            for data in result {
                //gets the rccd filename from the result data.
                let tempRCCDName = data.rccdname
                
                //if the rccd filename mathches.
                if tempRCCDName == rccdname {
                    //deletes the data for that rccdfile from the database.
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
     This method is used to get the username corresponding to a service, with which the user have previously logged in.
     
     - Parameter service: The service name for which the username is required.
     - Returns: The username saved for that service, in String.
     */
    class func getUsername(from rccdFileName: String ,for service: String) -> String? {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates the request to fetch the user entity.
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [User] else {
                print("invalid result found.")
                return nil
            }
            
            //iterating through the result array.
            for data in result {
                //gets the rccdfilename and service associated with it from the result data.
                let tempService = data.service
                let tempRCCD = data.rccdname
                
                //if the service matches.
                if service == tempService && rccdFileName == tempRCCD {
                    
                    //returns the username corresponding to the service.
                    return data.username
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    
    /**
     This method is used to get the rccd filename of the given service, with which the user have previously logged in.
     
     - Parameter service: The service name  whose rccd filename is required.
     - Returns: The rccd filename saved for the given service, in String.
     */
    class func getRCCDName(for service: String) -> String? {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates the request to fetch the user entity.
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [User] else {
                print("invalid result found.")
                return nil
            }
            
            //iterating through the result array.
            for data in result {
                let tempService = data.service
                
                //if the service matches.
                if service == tempService {
                    
                    //returns the rccd filename corresponding to this service.
                    return data.rccdname
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    /*
     * This method is used to get the last input values of the user.
     - Returns : The User model, with the last entered values by the user.
     */
    class func getLastSavedEntry() -> User? {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates the requst for user entity.
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //validates the result obtained.
            guard let result = try context.fetch(fetchReq) as? [User], result.count > 0 else {
                print("invalid result.")
                return nil
            }
            //returns the last value of the result array.
            return result.last
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    /**
     This method is used to delete all the data corresponding to the user entity.
     All the data corresponding to the user values, will be deleted , and the application will be reset to its default state.
     */
    class func deleteAllData() {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates the request to fetch the user entity
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result of the request, an User array.
            guard let result = try context.fetch(request) as? [User] else {
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
