//
//  CertificateHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import Cocoa

public class CertificateHandler {
    enum InstallCertificateError: Error {
        case FromData // "Could not create certificate from data."
    }
    
    //MARK:- Class Methods

    /**
     This method is used to get URL of Keychain.
     - Returns: A URL, Url of Keychain from device
     */
    class func getKeychainURL() -> URL {
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Keychains").appendingPathComponent("login.keychain")
        return(url)
    }
 
    /**
     This method is used to load and trust the certificate to Keychain.
     - Parameter data: the data of the certificate to be loaded to keychain.
     - Parameter toTrust: the bool value indicating whether to trust the certificate or not.
     */
    class func loadCertificate(data: Data, toTrust:Bool) throws {
        do {
            //get the certificate
            let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData)
            if certificate == nil {
                throw InstallCertificateError.FromData
            }
            //open Keychain
            let kc = try Keychain.Open(path: FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Keychains").appendingPathComponent("login.keychain").path)
            
            let err = SecCertificateAddToKeychain(certificate!, kc._keychain)
            if err == errSecSuccess {
                if(toTrust)
                {
                    //trust certificate
                    SecTrustSettingsSetTrustSettings(certificate!, SecTrustSettingsDomain.user, nil)
                }
            } else if err == errSecDuplicateItem {
            } else {
                throw make_sec_error(err, "Cannot create keychain")
            }
            
        } catch let err as NSError {
            print("Error \(err.code) in \(err.domain) : \(err.localizedDescription)")
        }
    }
    
    /**
     This method is used to delete the certificate in Keychain.
     - Parameter certificateToBeDeleted: the certificate that needs to be deleted from the database as well as Keychain.
     */
    class func deleteCertificate(certificateToBeDeleted : SecKeychainItem) {
        do{
            let kc = try Keychain.Open(path: getKeychainURL().path)
        }
        catch let err as NSError
        {
            NSLog("Error \(err.code) in \(err.domain) : \(err.localizedDescription)")
            NotificationManager.sharedManager().showNotification(informativeText: "Error while deleting certificates: \(err.localizedDescription).")
        }
    }
   
    /**
     This method is used to delete the certificate on the basis if Fingerprint.
     - Parameter fingerprint: the fingerprint key from the database as well as keychain.
     */
    class func deleteCertificates(fingerprint: String) {
        do{
            //get certificates from Keychain
            let kc = try Keychain.Open(path: getKeychainURL().path)
            let identities  = try kc.SearchIdentities(maxResults: 1000)
            let defaults = UserDefaults.standard
            var certificates = [String: Any]()
            if let v = defaults.dictionary(forKey: "certificates") {
                certificates = v
            }
            for identity in identities {
                let certificate = try identity.getCertificate();
                if certificate.fingerprint() == fingerprint {
                    //delete certificate on basis of fingerprint
                    try kc.DeleteItem(item: certificate.ItemRef)
                }
            }
        }
        catch let err as NSError
        {
            NSLog("Error \(err.code) in \(err.domain) : \(err.localizedDescription)")
        }
    }
}
