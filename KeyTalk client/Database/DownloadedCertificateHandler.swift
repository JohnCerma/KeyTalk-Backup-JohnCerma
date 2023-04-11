//
//  DownloadedCertificateHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import CoreData
import AppKit


// For Downloaded Certificate Handling with the database.
class DownloadedCertificateHandler {
    
    /**
     This method is used to save the downloaded p12 certificate from the server into the database to handle the background recreation of the certificate after it gets expired.
     - Parameter toBeStored: the certificate needed to be stored in the database. In DownloadedCertificate format
     */
    class func saveDownloadedCertificate(certificate toBeStored: TrustedCertificate) {
        //getting the context object for the database.
        let context = PersistenceService.context
        
        //checks wheather the certificate is already in the database or not.
        if alreadyInDatabase(toBeChecked: toBeStored) {
            // updates the values of the new certificate in database with the old one, if the certificate already exists.
            updateEntityWithNewValues(tobeUpdated: toBeStored)
        }
        else {
            //if the file is not avalaible in the database.
            //creating the config entity.
            let entity = NSEntityDescription.entity(forEntityName: "DownloadedCert", in: context)
            
            //Gets the downloaded certificate object from the database with the above entity.
            let newCertEntity = NSManagedObject(entity: entity!, insertInto: context) as? DownloadedCert
            
            if let _newCertEntity = newCertEntity {
                
                do {
                    //gets the usermodel associated with the certificate
                    let jsonData = try JSONEncoder().encode(toBeStored.downloadedCert?.user[0])
                    let userStr = String.init(data: jsonData, encoding: .utf8)
                   
                    //sets the usermodel or ini file information in the entity.
                    _newCertEntity.userInfo = userStr
                    
                }   catch {
                    print("unable to parse to data")
                }
                
                if let trustedCertInfo = toBeStored.downloadedCert?.cert {
                    
                    //sets the certificate related information in the database with their respective attributes.
                    _newCertEntity.certRCCDName = toBeStored.downloadedCert?.rccdName
                    _newCertEntity.certDownloadTime = trustedCertInfo.downloadTime
                    _newCertEntity.certExpiryTime = trustedCertInfo.expiryTime
                    _newCertEntity.certData = trustedCertInfo.data
                    _newCertEntity.certValidPer = Int16(trustedCertInfo.validPercent ?? 0)
                    _newCertEntity.certValidTime = trustedCertInfo.validTime
                    _newCertEntity.certNotificationShown = Int16(trustedCertInfo.notificationShown)
                    _newCertEntity.certServiceName = trustedCertInfo.associatedServiceName
                    _newCertEntity.certFingerPrint = trustedCertInfo.fingerPrint
                    _newCertEntity.isSMIME = trustedCertInfo.isSMIME
                    _newCertEntity.certServiceUri = trustedCertInfo.serviceUri
                    _newCertEntity.certUsername = trustedCertInfo.username
                    _newCertEntity.certChallenge = trustedCertInfo.challenge
                    _newCertEntity.serialNumber = trustedCertInfo.serialNumber
                    _newCertEntity.commonName = trustedCertInfo.commonName
                    _newCertEntity.certCRLURL = trustedCertInfo.crlURL
                    
                }
                
                //saves the new context.
                PersistenceService.saveContext()
            }
        }
    }
    
    /**
     This method will return all the certificates which were downloaded and trusted by the user through the keytalk client after completing the authentication process.
     Only those certificates which were downloaded and stored in the keychain will be returned.
     
     - Returns: An array of all the certificates downloaded by the application. type TrustedCertificate
    */
    class func getTrustedCertificateData() -> [TrustedCertificate]? {
        let context = PersistenceService.persistentContainer.viewContext
        
        //initializing a array variable of type UserModel. To store all the services data.
        var trustedCertArr = [TrustedCertificate]()
        
        //creates a request to fetch the data from the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedCert")
        
        request.returnsObjectsAsFaults = false
       
        DispatchQueue.main.async {
        
        do {
            //gets the result for the request, an config array type.
            let result = try context.fetch(request) as? [DownloadedCert]
            
            if let _result = result {
                //iterating all the results.
                for data in _result {
                    
                    var userInfoJson: UserModel?
                    let tempTrustedUserInfo = data.value(forKey: "userInfo") as? String
                    if let _tempTrustedUserInfo = tempTrustedUserInfo {
                        let data = _tempTrustedUserInfo.data(using: .utf8, allowLossyConversion: false)
                        if let _data = data {
                            do {
                                //decoding/deserializing the json data into the UserModel type.
                                userInfoJson = try JSONDecoder().decode(UserModel.self, from: _data)
                            }
                            catch (let error as NSError) {
                                print("Json decoding failed...... " + error.description)
                            }
                        }
                    }
                    
                    ///getting the certificate values...
                    let tempTrustedCertRCCDName = data.value(forKey: "certRCCDName") as? String
                    let tempTrustedCertDownloadTime = data.value(forKey: "certDownloadTime") as! Double
                    let tempTrustedCertExpiryTime = data.value(forKey: "certExpiryTime") as! Double
                    let tempTrustedCertData = data.value(forKey: "certData") as! Data
                    let tempTrustedCertFingerPrint = data.value(forKey: "certFingerPrint") as? String
                    let tempTrustedCertisSMIME = data.value(forKey: "isSMIME") as? Bool
                    let tempTrustedCertNotificationShown = data.value(forKey: "certNotificationShown") as! Int
                    let tempTrustedCertCRLURL = data.value(forKey: "certCRLURL") as? String
                    let tempTrustedCertValidPer = data.value(forKey: "certValidPer") as? Int
                    let tempTrustedCertValidTime = data.value(forKey: "certValidTime") as? String
                    let tempTrustedCertServiceName = data.value(forKey: "certServiceName") as? String
                    let tempTrustedCertUsername = data.value(forKey: "certUsername") as? String
                    let tempTrustedCertServiceUri = data.value(forKey: "certServiceUri") as? String
                    let tempTrustedCertChallenge = data.value(forKey: "certChallenge") as? String
                    let tempTrustedCertSerialNumber = data.value(forKey: "serialNumber") as! String
                    let tempTrustedCertCommonName = data.value(forKey: "commonName") as! String
                    
                    //creting a P12Certificare instance with the above retrieved values.
                    let retrivedCertInfo = P12Certificate(downloadTime: tempTrustedCertDownloadTime, expiryTime: tempTrustedCertExpiryTime, data: tempTrustedCertData , validPercent: tempTrustedCertValidPer, validTime: tempTrustedCertValidTime, fingerPrint: tempTrustedCertFingerPrint!, associatedServiceName: tempTrustedCertServiceName!, username: tempTrustedCertUsername!, isSMIME: tempTrustedCertisSMIME ?? false,serviceUri: tempTrustedCertServiceUri!, challenge: tempTrustedCertChallenge, notificationShown: tempTrustedCertNotificationShown, serialNumber: tempTrustedCertSerialNumber, commonName: tempTrustedCertCommonName, crlURL: tempTrustedCertCRLURL)
                 
                    //creating a TrustesCertificate instance and initializing its attributes with the above obtained values.
                    let tempTrustedCert = TrustedCertificate(downloadedCert: DownloadedCertificate(rccdName: tempTrustedCertRCCDName, user: [userInfoJson!], cert: retrivedCertInfo))
                    
                    //appending it into the array.
                    trustedCertArr.append(tempTrustedCert)
                }
            }
        } catch {
            print("Failed")
        }
    }
        
        return trustedCertArr
    }
 
    /**
     This method will check wheather the given Trusted Certificate is present or not in the database.
     - Parameter toBeChecked: The value which needs to be checked within the database, type TrustedCertificate
     - Returns: A bool value notifying the presense of an entity within the database.
     */
    class func alreadyInDatabase(toBeChecked:TrustedCertificate) -> Bool  {
        //bool value, to show the presense of an entity within the database
        var isPresent = false
        
        //context of the database
        let context = PersistenceService.persistentContainer.viewContext
    
        //creates a request to fetch the data from the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedCert")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an config array type.
            let result = try context.fetch(request) as? [DownloadedCert]
            if let _result = result {
                for data in _result {
                    
                    let tempCertServiceName = data.value(forKey: "certServiceName") as? String
                    let tempCertUsername = data.value(forKey: "certUsername") as? String
                    let tempCertServiceUri = data.value(forKey: "certServiceUri") as? String
                    let tempCertRCCDName = data.value(forKey: "certRCCDName") as? String
                    
                    //varifying/matching the retrieved result with the input certificate information.
                    if tempCertServiceName == toBeChecked.downloadedCert?.cert?.associatedServiceName &&  tempCertUsername == toBeChecked.downloadedCert?.cert?.username && tempCertServiceUri == toBeChecked.downloadedCert?.cert?.serviceUri && tempCertRCCDName == toBeChecked.downloadedCert?.rccdName {
                        
                        //if the values matched with the one stored in the database, i.e the value is present in the database.
                        isPresent = true
                    }
                }
            }
        } catch {
            print("unable to retrieve")
        }
        return isPresent
    }
    
    /**
     This method is used to update the values of the downloaded certificate with the values of the new certificate which is downloaded again after the expiry of the previous certificate.
     - Parameter tobeUpdated: The new certificate , the previous stored certificate informations are updated with information of this certificate.
     */
    class func updateEntityWithNewValues (tobeUpdated : TrustedCertificate) {
        
        //getting the certificate informations.
        let certInfo = tobeUpdated.downloadedCert?.cert
        
        let context = PersistenceService.persistentContainer.viewContext

        //creates a request to fetch the data from the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedCert")
        
        //setting the parameters for the searching in the database.
        //matching the saved certificate with its username password servicename and the service uri, which are unique for each certificate.
        request.predicate = NSPredicate(format: "certRCCDName = %@ AND certServiceName = %@ AND certUsername = %@ AND certServiceUri = %@" ,
                                        argumentArray: [tobeUpdated.downloadedCert?.rccdName as Any ,certInfo?.associatedServiceName as Any , certInfo?.username as Any ,certInfo?.serviceUri as Any])
        do {
            let results = try context.fetch(request) as? [DownloadedCert]
            if results?.count == 1 {
                // Atleast one was returned or matched.
                if let _results = results {
                    for data in _results {
                        
                        //updating the stored attributes with the information of the new certificates.
                        //deletePreviousStoredCertificate(fingerprint: (data.value(forKey: "certFingerPrint") as! String))
                        
                        data.setValue(certInfo?.downloadTime, forKey: "certDownloadTime")
                        data.setValue(certInfo?.expiryTime, forKey: "certExpiryTime")
                        data.setValue(certInfo?.data, forKey: "certData")
                        data.setValue(certInfo?.validPercent, forKey: "certValidPer")
                        data.setValue(certInfo?.validTime, forKey: "certValidTime")
                        data.setValue(certInfo?.fingerPrint, forKey: "certFingerPrint")
                        data.setValue(certInfo?.isSMIME, forKey: "isSMIME")
                        data.setValue(certInfo?.notificationShown , forKey: "certNotificationShown")
                        data.setValue(certInfo?.serialNumber, forKey: "serialNumber")
                        data.setValue(certInfo?.crlURL, forKey: "certCRLURL")
                    }
                }
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        do {
            //saves the context of the database.
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    /**
     This method is used to delete the downloaded certificate if its rccd is removed from the database.
     */
    class func deleteItem(rccdInfo: rccd) {
        
            let context = PersistenceService.persistentContainer.viewContext
            
            //creates a request to fetch the data from the database.
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedCert")
            
            //setting the parameters for the searching in the database.
            //matching the saved certificate with its username password servicename and the service uri, which are unique for each certificate.
            request.predicate = NSPredicate(format: "certRCCDName = %@"  ,argumentArray: [rccdInfo.name as Any])
            do {
                let results = try context.fetch(request) as? [DownloadedCert]
                guard let _results = results , _results.count == 1 else {
                    return
                }
                // Atleast one was returned or matched.
                if !_results[0].isSMIME {
                    CertificateHandler.deleteCertificates(fingerprint: _results[0].certFingerPrint!)
                }
                context.delete(_results[0])
            } catch {
                print("Fetch Failed: \(error)")
            }
            PersistenceService.saveContext()
    }
    
    /*This will delete all the services and rccd files present inside the database or app and will reset the application into its default state.
    */
    class func deleteAllData() {
        let context = PersistenceService.persistentContainer.viewContext
        
        //creates a request to fetch the contents of the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedCert")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result from the request.
            let result = try context.fetch(request) as? [DownloadedCert]
            
            //iterating through the array of results.
            if let _result = result {
                for data in _result {
                    if !data.isSMIME {
                        CertificateHandler.deleteCertificates(fingerprint: data.certFingerPrint!)
                        //deleting all the data present in the result array.
                        context.delete(data)
                    }
                }
            }
            //saves the database context after deleting all the data form it.
            PersistenceService.saveContext()
        } catch {
            print("Failed")
        }
    }
    
    /*This will delete the previously stored certificate.
     */
    class func deletePreviousStoredCertificate(fingerprint toBeDeleted : String?) {
        if let _fingerprintToBeDeleted = toBeDeleted {
            CertificateHandler.deleteCertificates(fingerprint: _fingerprintToBeDeleted)
        }
    }
    
    /**
     This function will return the TrustedCertificate stored in the database on the basis of RCCD file name and Service it is associated with.
     - Parameter rccd name: The RCCD file name to which the service is associated with.
     - Parameter for service : The service name for which the certificate information is required.
     - Returns: The TrustedCertificate associated with the service in the given RCCD File.
     */
    class func getCertificateInformation(rccd name : String , for service : String) -> TrustedCertificate? {
        //gets the context of the persistant container.
        let context = PersistenceService.persistentContainer.viewContext
        
        //initializing a variable of type TrustedCertificate. To store all the certificate data.
        var trustedCert : TrustedCertificate?
        
        //creates a request to fetch the data from the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedCert")
        
        request.predicate = NSPredicate(format: "certRCCDName = %@ AND certServiceName = %@"  ,argumentArray: [name as Any, service as Any])
        //request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an config array type.
            let result = try context.fetch(request) as? [DownloadedCert]
            
            if let _result = result {
                //iterating all the results.
                for data in _result {
                    
                    var userInfoJson: UserModel?
                    let tempTrustedUserInfo = data.value(forKey: "userInfo") as? String
                    if let _tempTrustedUserInfo = tempTrustedUserInfo {
                        let data = _tempTrustedUserInfo.data(using: .utf8, allowLossyConversion: false)
                        if let _data = data {
                            do {
                                //decoding/deserializing the json data into the UserModel type.
                                userInfoJson = try JSONDecoder().decode(UserModel.self, from: _data)
                            }
                            catch (let error as NSError) {
                                print("Json decoding failed...... " + error.description)
                            }
                        }
                    }
                    
                    ///getting the certificate values...
                    let tempTrustedCertRCCDName = data.value(forKey: "certRCCDName") as? String
                    let tempTrustedCertDownloadTime = data.value(forKey: "certDownloadTime") as! Double
                    let tempTrustedCertExpiryTime = data.value(forKey: "certExpiryTime") as! Double
                    let tempTrustedCertData = data.value(forKey: "certData") as! Data
                    let tempTrustedCertFingerPrint = data.value(forKey: "certFingerPrint") as? String
                    let tempTrustedCertisSMIME = data.value(forKey: "isSMIME") as? Bool
                    let tempTrustedCertNotificationShown = data.value(forKey: "certNotificationShown") as! Int
                    let tempTrustedCertCRLURL = data.value(forKey: "certCRLURL") as? String
                    let tempTrustedCertValidPer = data.value(forKey: "certValidPer") as? Int
                    let tempTrustedCertValidTime = data.value(forKey: "certValidTime") as? String
                    let tempTrustedCertServiceName = data.value(forKey: "certServiceName") as? String
                    let tempTrustedCertUsername = data.value(forKey: "certUsername") as? String
                    let tempTrustedCertServiceUri = data.value(forKey: "certServiceUri") as? String
                    let tempTrustedCertChallenge = data.value(forKey: "certChallenge") as? String
                    let tempTrustedCertSerialNumber = data.value(forKey: "serialNumber") as! String
                    let tempTrustedCertCommonName = data.value(forKey: "commonName") as! String
                    
                    //creting a P12Certificare instance with the above retrieved values.
                    let retrivedCertInfo = P12Certificate(downloadTime: tempTrustedCertDownloadTime, expiryTime: tempTrustedCertExpiryTime, data: tempTrustedCertData , validPercent: tempTrustedCertValidPer, validTime: tempTrustedCertValidTime, fingerPrint: tempTrustedCertFingerPrint!, associatedServiceName: tempTrustedCertServiceName!, username: tempTrustedCertUsername!, isSMIME: tempTrustedCertisSMIME ?? false,serviceUri: tempTrustedCertServiceUri!, challenge: tempTrustedCertChallenge, notificationShown: tempTrustedCertNotificationShown, serialNumber: tempTrustedCertSerialNumber, commonName: tempTrustedCertCommonName, crlURL: tempTrustedCertCRLURL)
                    
                    //creating a TrustesCertificate instance and initializing its attributes with the above obtained values.
                    let tempTrustedCert = TrustedCertificate(downloadedCert: DownloadedCertificate(rccdName: tempTrustedCertRCCDName, user: [userInfoJson!], cert: retrivedCertInfo))
                    
                    //storing the temp variable value.
                    trustedCert = tempTrustedCert
                }
            }
        } catch {
            print("Failed")
        }
        return trustedCert
    }
}
