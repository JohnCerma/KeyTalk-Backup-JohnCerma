//
//  CertificateLoader.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import AppKit

class CertificateLoader {
    var mChoosenCertificate : KeychainCertificate? = nil
    var certDict : [String:Any] = [:]

    //MARK:- public Methods
    
    /**
     This method is used to load p12 certificate to Keychain.
     - Parameter path: the path of the downloaded certificate.
     - Parameter p12Password: the password of the p12 certificate.
     - Parameter isUserInitiated: the bool value indicating whether the loading is user initiated or automatic.
     - Parameter certificateModel: the download cerrtificate model to store data in database.
     - Parameter aServiceUsername: the username of the service.
     - Parameter aServiceName: the service name corresponding to the certificate that needs to be loaded.
     - Parameter completion: This is to notify the status of execution of the function to the base class.
     */
    func loadPKCSCertificate(path:String, p12Password: String, isUserInitiated:Bool, certificateModel:DownloadedCertificate?, aServiceUsername:String,aServiceName:String , completion : @escaping (_ status : Bool) -> ())
    {
        //get certificate list from Keychain
        let keychainCertificateBeforeImport = KCServices.getCertificateInfoList()

        var _: SecIdentity? = nil
        //convert cert to data
        let PKCS12Data = NSData(contentsOfFile: path ) as Data?
        let inPKCS12Data = PKCS12Data!
        let _password = p12Password
        let options = [ kSecImportExportPassphrase as String: _password ]
        var rawItems: CFArray?
        
        var isCertSMIME:Bool = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            //status of imported certificate
            let status = SecPKCS12Import(inPKCS12Data as CFData,
                                         options as CFDictionary,
                                         &rawItems)
            
            if status == errSecSuccess {
                //if successfully imported
                let certDownloadTime = NSDate().timeIntervalSinceReferenceDate
                
                let items = rawItems! as! Array<Dictionary<String, Any>>
                let firstItem = items[0]
                let certLabel = firstItem["label"] as! String
                
                self.certDict[certLabel] = firstItem["identity"] as! SecIdentity
                let keychainCertificateaAfterImport = KCServices.getCertificateInfoList()
                let beforeImportArr = keychainCertificateBeforeImport[KEY_KEYTALK_CERTIFICATE]
                let afterImportArr = keychainCertificateaAfterImport[KEY_KEYTALK_CERTIFICATE]
                
                //last downloaded certificate
                let lastDownloadedKeytalkCert =  beforeImportArr!.difference(from: afterImportArr!)
                
                //Saving the context of the downloaded certificate
                var tempDownloadedCertModel = certificateModel
                if tempDownloadedCertModel?.cert == nil && lastDownloadedKeytalkCert.count > 0 {
                    let challenegResponseStr = gChallengeModelStr
                    
                    //check if certificate is SMIME or not
                    if (((lastDownloadedKeytalkCert[0][KEY_EXTENDED_KEY_USAGE] as? String) != nil) && ((lastDownloadedKeytalkCert[0][KEY_SUBJECT_ALTERNATE_NAME] as? String) != nil)) {
                        isCertSMIME = true
                    } else {
                        isCertSMIME = false
                    }
                    
                    //store certificate information to database
                    let tempCertModel = P12Certificate.init(downloadTime: certDownloadTime, expiryTime: lastDownloadedKeytalkCert[0][KEY_EXPIRY_DATE] as! TimeInterval, data: inPKCS12Data, validPercent: ((tempDownloadedCertModel?.user[0].Providers[0].Services[0].CertValidPercent)), validTime: ((tempDownloadedCertModel?.user[0].Providers[0].Services[0].CertValidity)), fingerPrint:  lastDownloadedKeytalkCert[0][KEY_FINGERPRINT] as! String, associatedServiceName: aServiceName, username: aServiceUsername, isSMIME: isCertSMIME, serviceUri: (tempDownloadedCertModel?.user[0].Providers[0].Server)!, challenge: challenegResponseStr, notificationShown: 0, serialNumber: lastDownloadedKeytalkCert[0][KEY_SERIAL_NUMBER] as! String, commonName: lastDownloadedKeytalkCert[0][KEY_COMMON_NAME] as! String, crlURL: lastDownloadedKeytalkCert[0][KEY_CRL_URL] as? String)
                    
                    tempDownloadedCertModel?.cert = tempCertModel
                    DownloadedCertificateHandler.saveDownloadedCertificate(certificate: TrustedCertificate(downloadedCert: tempDownloadedCertModel))
                    Utilities.resetGlobalMemberVariablesAccordingToUseCase(isUserInitiated: isUserInitiated)
                    
                    print("Success opening p12 certificate. Items: \(CFArrayGetCount(items as CFArray))")
                    if isUserInitiated {
                        //close the window when certificate installed
                    
                        // Change as per the requirements
                        //  NSApplication.shared.windows[0].close()
                        NotificationManager.sharedManager().showNotification(informativeText: "Certificate added successfully to the Keychain".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
                        
                        
                    }
                    Utilities.init().logger.write("Certificate with Commom Name: \(String(describing: lastDownloadedKeytalkCert[0][KEY_COMMON_NAME]!)), Serial Number: \(String(describing: lastDownloadedKeytalkCert[0][KEY_SERIAL_NUMBER]!)), Expiry Date: \(String(describing: lastDownloadedKeytalkCert[0][KEY_EXPIRY_DATE]!)) added successfully to the Keychain")
                    completion(true)
                    
                    
                } else {
                    NotificationManager.sharedManager().showNotification(informativeText: "Certificate could not be installed because it already exists".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
                    Utilities.init().logger.write("Authentication was successful, certificate and key were successfully installed")
                    
                    Utilities.showAlertForCertificateAlreadtExistsMessage(aMessageText: "Authentication was successful, certificate and key were successfully installed")
                    
                    completion(false)
                    
                    
                }
                
                
                
            } else {
                print("Error opening Certificate.")
                NotificationManager.sharedManager().showNotification(informativeText: "Certificate could not be installed because it already exists".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
                    Utilities.init().logger.write("Certificate could not be added to the Keychain")
                
                Utilities.showAlertForCertificateAlreadtExistsMessage(aMessageText: "Certificate could not be added to the Keychain because it already exists")
                
                completion(false)
                
                
            }
        })
    }
    
    /**
     This method is used to load der certificate to Keychain.
     - Parameter path: the path of the downloaded certificate.
     */
    func loadDERCertificate(path:String)
    {
        //certificate data
        var certificateData = Data()
        //let urlStr = "file://" + path
         let url = URL.init(fileURLWithPath: path)  //URL.init(string: path)
//        if let url = url {
            let str = try! Data.init(contentsOf: url)
            certificateData = str
        
//        }
        //save data to Keychain
        saveToKeychain(data: certificateData)
    }
    
    /**
     This method is used to save the certificate to Keychain.
     - Parameter data: the data of the downloaded certificate.
     */
    func saveToKeychain(data : Data)
    {
        do{
            let defaults = UserDefaults.standard
            
            let mSelectedCerificate = SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData)
            if(mSelectedCerificate != nil)
            {
                mChoosenCertificate = KeychainCertificate(certificate: mSelectedCerificate!)
                certDict[(mChoosenCertificate?.SubjectSummary)!] = mSelectedCerificate!.hashValue
                defaults.set(certDict, forKey: "certificates")
                defaults.synchronize()
            }
            try CertificateHandler.loadCertificate(data: data,toTrust: true)
        }
        catch let err as NSError {
            print("Error \(err.code) in \(err.domain) : \(err.localizedDescription)")
        }
    }
}

