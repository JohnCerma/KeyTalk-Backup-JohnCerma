//
//  DBHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import CoreData
import AppKit

// For RCCD
class DBHandler {
    
    /**
     This method is used to save the RCCD file data into the core Data or database.
     
     - Parameter json: The contents of user.ini file in the json format .
     - Parameter aImageData: The provider icon in the Data format.
     */
    class func saveToDatabase(rccd name: String, withConfig json: String, aImageData: Data?) {
        
        //getting the context object for the database.
        let context = PersistenceService.context
        
        //checks wheather the rccd file is already in the database or not.
        if alreadyInDatabase(key: json) {
            
            // Show alert already in database, if the file already exists.
            DispatchQueue.main.async {
                Utilities.showAlert(aMessageText: "rccd_already_imported_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
                Utilities.init().logger.write("RCCD file has already been imported.")
            }
        }
        else {
            //if the file is not avalaible in the database.
            
            //creating the config entity.
            let entity = NSEntityDescription.entity(forEntityName: "RCCD", in: context)
            
            //Gets the config object from the database with the above entity.
            let newConfig = NSManagedObject(entity: entity!, insertInto: context) as? RCCD
            if let _newConfig = newConfig {
                
                //set the name of the rccd file.
                _newConfig.rccdName = name
                
                //sets the configInfo with the json parameter.
                _newConfig.iniInfo = json
                
                if let imageData = aImageData {
                    
                    //sets the image Data with the parameter aImageData.
                    _newConfig.imageData = imageData
                }
                //the context is saved with the contents of the imported RCCD file.
                PersistenceService.saveContext()
                
                DispatchQueue.main.async {
                    NotificationManager.sharedManager().showNotification(informativeText: "rccd_suceess_imported_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
                }
            }
        }
    }
    
    /**
     This method checks wheather there is any value corresponding to a parameter key in the database.
     - Parameter key: The key for which the value needs to be checked, in string type.
     - Returns: A bool value, corresponding to the avalaiblity of the data in the database for the key.
     */
    class func alreadyInDatabase(key: String) -> Bool {
        //gets the context of the database.
        let context = PersistenceService.persistentContainer.viewContext
        
        //variable indicating the presence of key in the database, default set to false.
        var keyInDB = false
        
        //create the fetch request from the config entity.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RCCD")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request.
            let result = try context.fetch(request) as? [RCCD]
            if let _result = result {
                
                //iterating through the result obtained.
                for data in _result {
                    
                    //gets the key value from the config entity data.
                    let tempConfig = data.value(forKey: "iniInfo") as? String
                    
                    //if the config key equals to the parameter key, then the database already have a value corresponding to that key.
                    if tempConfig == key && tempConfig != nil {
                        
                        //sets the variable to true, indicating the presence of the key in the database.
                        keyInDB = true
                        break
                    }
                }
            }
        } catch {
            Utilities.init().logger.write("Failed to check the key in the database")
        }
        
        return keyInDB
    }
    
    /**
     This method checks wheather there is any value corresponding to a parameter key in the database.
     - Parameter key: The key for which the value needs to be checked, in string type.
     - Returns: A bool value, corresponding to the avalaiblity of the data in the database for the key.
     */
    class func getRCCD(rccdName: String) -> rccd? {
        //gets the context of the database.
        let context = PersistenceService.persistentContainer.viewContext
        
        var rccdFile : rccd?
        
        //create the fetch request from the config entity.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RCCD")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request.
            let result = try context.fetch(request) as? [RCCD]
            if let _result = result {
                
                //iterating all the results.
                for data in _result {
                    
                    let name = data.value(forKey: "rccdName") as? String
                    
                    
                    if name == rccdName && name != nil {
                        
                        //gets the json data, type string.
                        let tempConfig = data.value(forKey: "iniInfo") as? String
                        
                        //gets the image icon data, type Data.
                        let imageData = data.value(forKey: "imageData") as? Data
                        
                        // Convert To data
                        if let configStr = tempConfig {
                            
                            //encoding the json string.
                            let data1 = configStr.data(using: .utf8, allowLossyConversion: false)
                            if let _data = data1 {
                                var configJson: UserModel?
                                do {
                                    //decoding/deserializing the json data into the RCCD type.
                                    configJson = try JSONDecoder().decode(UserModel.self, from: _data)
                                    
                                    //sets the provider image logo with the imageData from Database.
                                    configJson?.Providers[0].imageLogo = imageData
                                    
                                    var configJSONArr = [UserModel]()
                                    configJSONArr.append(configJson!)
                                    rccdFile = rccd(name: name!, imageData: imageData!, users: configJSONArr)
                                }
                                catch (let error as NSError) {
                                    print("Json decoding failed...... " + error.description)
                                    Utilities.init().logger.write("Json decoding failed...... \(error.description)")
                                }
                            } else {
                                //Invalid Data Retrieved.
                            }
                        }
                    } else {
                        //filename not foun
                    }
                }
            }
        } catch {
            Utilities.init().logger.write("Failed to check the key in the database")
        }
        
        return rccdFile
    }
    
    /**
     This method checks whether there is any value corresponding to a parameter key in the database.
     - Parameter Key: The serial number for which the value needs to be checked, in string type.
     - Returns: A P12Certificate, corresponding to the avalaiblity of the data in the database for the key.
     */
    class func getDataforSerialNumber(serialNumber: String) -> P12Certificate? {
        //gets the context of the database.
        let context = PersistenceService.persistentContainer.viewContext
        
        var p12Cert : P12Certificate?
        
        //create the fetch request from the config entity.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedCert")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request.
            let result = try context.fetch(request) as? [DownloadedCert]
            if let _result = result {
                
                //iterating all the results.
                for data in _result {
                    
                    let serialNum = data.value(forKey: "serialNumber") as? String
                    
                    
                    if serialNum == serialNumber && serialNum != nil {
                        
                        let certData = data.value(forKey: "certData") as? Data
                        let isSmime = data.value(forKey: "isSMIME") as? Bool
                        let downloadTime = data.value(forKey: "certDownloadTime") as? TimeInterval
                        let expiryTime = data.value(forKey: "certExpiryTime") as? TimeInterval
                        let validPercent = data.value(forKey: "certValidPer") as? Int
                        let validTime = data.value(forKey: "certValidTime") as? String
                        let fingerPrint = data.value(forKey: "certFingerPrint") as? String
                        let associatedServiceName  = data.value(forKey: "certServiceName") as? String
                        let username = data.value(forKey: "certUsername") as? String
                        let serviceUri = data.value(forKey: "certServiceUri") as? String
                        let challenge  = data.value(forKey: "certChallenge") as? String?
                        let notificationShown = data.value(forKey: "certNotificationShown") as? Int
                        let commonName  = data.value(forKey: "commonName") as? String
                        let crlURL = data.value(forKey: "certCRLURL") as? String?
                    
                        p12Cert = P12Certificate(downloadTime: downloadTime!, expiryTime: expiryTime!, data: certData!, validPercent: validPercent, validTime: validTime, fingerPrint: fingerPrint!, associatedServiceName: associatedServiceName!, username: username!, isSMIME: isSmime!, serviceUri: serviceUri!, challenge: challenge!, notificationShown: notificationShown!, serialNumber: serialNumber, commonName: commonName!, crlURL: crlURL!)
                    } else {
                        //serial number not found
                    }
                }
            }
        } catch {
            Utilities.init().logger.write("Failed to check the key in the database")
        }
        
        return p12Cert
    }
    
    
    /**
     This method is used to fetch all the services present inside the database.
     - Returns: An array of UserModel corresponding to different services and their providers.
     */
    class func getServicesData() -> [UserModel] {
        let context = PersistenceService.persistentContainer.viewContext
        
        //initializing a array variable of type UserModel. To store all the services data.
        var configDataArr = [UserModel]()
        
        //creates a request to fetch the data from the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RCCD")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an config array type.
            let result = try context.fetch(request) as? [RCCD]
            if let _result = result {
                //iterating all the results.
                for data in _result {
                    
                    //gets the json data, type string.
                    let tempConfig = data.value(forKey: "iniInfo") as? String
                    
                    //gets the image icon data, type Data.
                    let imageData = data.value(forKey: "imageData") as? Data
                    
                    // Convert To data
                    if let configStr = tempConfig {
                        
                        //encoding the json string.
                        let data1 = configStr.data(using: .utf8, allowLossyConversion: false)
                        if let _data = data1 {
                            var configJson: UserModel?
                            do {
                                //decoding/deserializing the json data into the RCCD type.
                                configJson = try JSONDecoder().decode(UserModel.self, from: _data)
                                
                                //sets the provider image logo with the imageData from Database.
                                configJson?.Providers[0].imageLogo = imageData
                            }
                            catch (let error as NSError) {
                                print("Json decoding failed...... " + error.description)
                                Utilities.init().logger.write("Json decoding failed...... \(error.description)")
                            }
                            //checks that there is some value in the data.
                            if let tempConfigJson = configJson {
                                //appending the data into the array.
                                configDataArr.append(tempConfigJson)
                            } else {
                                // Invalid RCCD Parser
                            }
                        } else {
                            //Invalid Data Retrieved.
                        }
                    }
                }
            }
        } catch {
            Utilities.init().logger.write("failed to get RCCD service data")
            
        }
        
        return configDataArr
    }
    
    /**
     This method is used to delete all the data present in the database.
     
     This will delete all the services and rccd files present inside the database or app and will reset the application into its default state.
     */
    class func deleteAllData() {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates a request to fetch the contents of the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RCCD")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result from the request.
            let result = try context.fetch(request) as? [RCCD]
            
            //iterating through the array of results.
            if let _result = result {
                for data in _result {
                    //deleting all the data present in the result array.
                    context.delete(data)
                }
            }
            //saves the database context after deleting all the data form it.
            PersistenceService.saveContext()
            UserDetailsHandler.deleteAllData()
        } catch {
            Utilities.init().logger.write("failed to delete RCCD entity data")
        }
    }
    
    /**
     This method gets all the RCCD data.
     - Returns: A [rccd], corresponding to the avalaiblity of the data in the database.
     */
    class func getRCCDData() -> [rccd]? {
        let context = PersistenceService.persistentContainer.viewContext
        
        //initializing a array variable of type UserModel. To store all the services data.
        var configDataArr = [UserModel]()
        var rccdDataArr = [rccd]()
        
        //creates a request to fetch the data from the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RCCD")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an config array type.
            let result = try context.fetch(request) as? [RCCD]
            if let _result = result {
                //iterating all the results.
                for data in _result {
                    //gets the name data, type string.
                    let tempRccdName = data.value(forKey: "rccdName") as? String
                    
                    //gets the json data, type string.
                    let tempConfig = data.value(forKey: "iniInfo") as? String
                    
                    //gets the image icon data, type Data.
                    let imageData = data.value(forKey: "imageData") as? Data
                    
                    // Convert To data
                    if let configStr = tempConfig {
                        
                        //encoding the json string.
                        let data1 = configStr.data(using: .utf8, allowLossyConversion: false)
                        if let _data = data1 {
                            var configJson: UserModel?
                            do {
                                //decoding/deserializing the json data into the RCCD type.
                                configJson = try JSONDecoder().decode(UserModel.self, from: _data)
                                //JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? rccd
                                
                                //sets the provider image logo with the imageData from Database.
                                configJson?.Providers[0].imageLogo = imageData
                                //configJson?.imageData = imageData!
                            }
                            catch (let error as NSError) {
                                print("Json decoding failed...... " + error.description)
                            }
                            //checks that there is some value in the data.
                            if let tempConfigJson = configJson {
                                var userModelArr = [UserModel]()
                                userModelArr.append(tempConfigJson)
                                let rccdJson = rccd(name: tempRccdName!, imageData: imageData!, users: userModelArr)
                                
                                //appending the data into the array.
                                configDataArr.append(tempConfigJson)
                                rccdDataArr.append(rccdJson)
                            } else {
                                // Invalid RCCD Parser
                            }
                        } else {
                            //Invalid Data Retrieved.
                        }
                    }
                }
            }
        } catch {
            Utilities.init().logger.write("failed to get RCCD data")
            
        }
        
        return rccdDataArr//configDataArr
    }
    
    /**
     This method removes a certain rccd information from database.
     - Parameter Key: The rccd toBeDeleted for which the value needs to be checked, in rccd type.
     */
    class func removeRCCDFromDB (rccd toBeDeleted: rccd ) {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates a request to fetch the data from the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RCCD")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an config array type.
            let result = try context.fetch(request) as? [RCCD]
            if let _result = result {
                //iterating all the results.
                for data in _result {
                    //gets the name data, type string.
                    let tempRccdName = data.value(forKey: "rccdName") as? String
                    
                    //gets the json data, type string.
                    let tempConfig = data.value(forKey: "iniInfo") as? String
                    
                    //gets the image icon data, type Data.
                    let imageData = data.value(forKey: "imageData") as? Data
                    
                    // Convert To data
                    if let configStr = tempConfig {
                        
                        //encoding the json string.
                        let data1 = configStr.data(using: .utf8, allowLossyConversion: false)
                        
                        if let _data = data1 {
                            //convert the given data into the string
                            let toBeDeletedUserModelStr =  String.init(data: _data, encoding: String.Encoding.utf8)
                            
                            if let rccdName = tempRccdName {
                                if let imgData = imageData {
                                    //validates the stored rccd name and imageData with the one to be deleted.
                                    if toBeDeleted.name == rccdName && toBeDeleted.imageData == imgData {
                                        if toBeDeletedUserModelStr != nil && configStr == toBeDeletedUserModelStr {
                                            context.delete(data)
                                            NotificationManager.sharedManager().showNotification(informativeText: "rccd_removed_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
                                            Utilities.init().logger.write("\(rccdName) removed successfully")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            do {
                try PersistenceService.context.save()
            }catch {
                Utilities.init().logger.write("Unable save RCCD file")
            }
        } catch {
            Utilities.init().logger.write("Unable to fetch RCCD entity from Core Data")
        }
    }
}


