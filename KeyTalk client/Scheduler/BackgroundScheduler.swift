//
//  BackgroundScheduler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Cocoa
import CoreData
import Foundation
import ServiceManagement


class BackgroundScheduler {
    
    //MARK:- Variables
    static var sSharedInstance : BackgroundScheduler?
    let lActivity =  NSBackgroundActivityScheduler.init(identifier:"com.keytalk.keytalkmacclient.Scheduler.BackgroundScheduler.tasks")
    
    //MARK:- Private Methods
    
    /**
     This method is used to initialize.
     */
    private init() {
    }
    
    /**
     This method is used to get the shared Instance of the class.
     */
    class func getSharedInstance() -> BackgroundScheduler {
        if BackgroundScheduler.sSharedInstance == nil {
            BackgroundScheduler.sSharedInstance = BackgroundScheduler()
        }
        return BackgroundScheduler.sSharedInstance!
    }
    
    /**
     This method is called whenever NSBackgroundActivityScheduler needs to be started.
     */
    func startActivity() {
        //NSBackgroundActivityScheduler schedules any activity that has to be run in the background. Continuously check for the expiry time of the certificates and download them again in case they are about to be expired.
        lActivity.invalidate()
        //set the repeat interval
        lActivity.interval = 20
        lActivity.repeats = true
        lActivity.tolerance = 0
        lActivity.qualityOfService = QualityOfService.userInitiated
        lActivity.schedule() {
            (completion: NSBackgroundActivityScheduler.CompletionHandler) in
            isBackgroundTaskRunning = true
            print("background task scheduled")
            // Perform the activity
            //NotificationManager.sharedManager().showNotification(informativeText: "helperAppDelegate::::")
            let lBackgroundTaskHandler = BackgroundTaskHandler()
            //get the CRL frequency from database
            if let crlFrequencyTime = CRLDBHandler.getCRLFrequencyTime() {
                var currentTime = NSDate().timeIntervalSinceReferenceDate
                // current time is greater than the CRL check time
                if currentTime > crlFrequencyTime {
                    //get the KeyTalk certificates downloaded
                    let lCertDataforCRLURL = DownloadedCertificateHandler.getTrustedCertificateData()//lBackgroundTaskHandler.getCerDataforCRLURL()
                    if lCertDataforCRLURL == nil {
                        //no KeyTalk certificate found with CRL
                        print("no keytalk certificate found")
                    } else {
                        for certData in lCertDataforCRLURL! {
                            //get CRL URL from downloaded KeyTalk certificate
                            let crlURL = certData.downloadedCert?.cert?.crlURL
                            //get Serial number from downloaded KeyTalk certificate
                            let serialNumber = certData.downloadedCert?.cert?.serialNumber
                            if let _crlURL = crlURL {
                                //download the CRL file from the URL found
                                Utilities.downloadCRLFile(url: _crlURL, aSerialNumber: serialNumber!)
                                var timeToCheck: Double = 0.0
                                if let frequency = CRLDBHandler.getCRLFrequency() {
                                     timeToCheck = currentTime + frequency
                                    //update the database with next CRL check time
                                    CRLDBHandler.saveCRLFrequencytoDatabase(timetoCheck: timeToCheck, frequencySelected: frequency)
                                    Utilities.init().logger.write("Next CRL check to be performed in \(timeToCheck) seconds")
                                }
                            } else {
                                //no CRL URL found
                                print("no crl found")
                            }
                        }
                    }
                }
                
            }
            
            //get KeyTalk certificates that are about to expire
            if let  lAboutToBeExpiredCertificates = lBackgroundTaskHandler.getAboutToBeExpiredCertificates()  {
                for aboutToBeExpiredCert in lAboutToBeExpiredCertificates {
                    //check if notification is shown
                    if aboutToBeExpiredCert.downloadedCert?.cert?.notificationShown == 0 {
                        let expiryUTCDateandTime = NSDate(timeIntervalSinceReferenceDate: (aboutToBeExpiredCert.downloadedCert?.cert?.expiryTime)!)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "hh:mm a, dd MMM yyyy"
                        let stringExpiryLocalDateandTime = dateFormatter.string(from: expiryUTCDateandTime as Date)
                        //show notification of the about to expire KeyTalk certificate
                        NotificationManager.sharedManager().showActionNotification(informativeText: "\("cert_service_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as? String ?? "en")) \(String(describing: (aboutToBeExpiredCert.downloadedCert?.user[0].Providers[0].Services[0].Name)!)) \("expiry_time_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as? String ?? "en")) \(stringExpiryLocalDateandTime)", identifier: "\((String(describing: (aboutToBeExpiredCert.downloadedCert?.rccdName)!))),\(String(describing: (aboutToBeExpiredCert.downloadedCert?.user[0].Providers[0].Services[0].Name)!))")
                        
                        Utilities.init().logger.write("\(String(describing: aboutToBeExpiredCert.downloadedCert?.cert?.commonName)) certificate with \(String(describing: aboutToBeExpiredCert.downloadedCert?.cert?.associatedServiceName)) service is about to expire in \(stringExpiryLocalDateandTime) seconds")
                        //update the database
                        var updatedCert = aboutToBeExpiredCert
                        updatedCert.downloadedCert?.cert?.notificationShown = 1
                        DownloadedCertificateHandler.saveDownloadedCertificate(certificate: updatedCert)
                    }
                }
            }
            
            //get KeyTalk certificates that are expired
            if let lExpiredCertificates = lBackgroundTaskHandler.getExpiredCertificates() {
                for lExpiredCerts in lExpiredCertificates {
                    //check if notification is shown
                    if (lExpiredCerts.downloadedCert?.cert?.notificationShown == 1 || lExpiredCerts.downloadedCert?.cert?.notificationShown == 0 ){
                        //show notification of the expired KeyTalk certificate
                        NotificationManager.sharedManager().showActionNotification(informativeText: "\("cert_with_service_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as? String ?? "en")) \(String(describing: (lExpiredCerts.downloadedCert?.user[0].Providers[0].Services[0].Name)!)) \("has_expired_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as? String ?? "en"))", identifier:"\((String(describing: (lExpiredCerts.downloadedCert?.rccdName)!))),\(String(describing: (lExpiredCerts.downloadedCert?.user[0].Providers[0].Services[0].Name)!))")
                        Utilities.init().logger.write("\(String(describing: lExpiredCerts.downloadedCert?.cert?.commonName)) certificate with \(String(describing: lExpiredCerts.downloadedCert?.cert?.associatedServiceName)) service has expired.")
                        
                        //update the database
                        var updatedCert = lExpiredCerts
                        updatedCert.downloadedCert?.cert?.notificationShown = 2
                        DownloadedCertificateHandler.saveDownloadedCertificate(certificate: updatedCert)
                    }
                }
            }
            
            completion(NSBackgroundActivityScheduler.Result.finished)
        }
    }
    
    /**
     This method is called whenever NSBackgroundActivityScheduler needs to be stopped.
     */
    func stopActivity() {
        if isBackgroundTaskRunning {
            lActivity.invalidate()
            isBackgroundTaskRunning = false
        }
    }
}
