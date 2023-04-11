//
//  BackgroundTaskHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//
import Foundation

class BackgroundTaskHandler {
    
    /**
     This method is used to get list of certificates that are about to be expired.
     - Returns: An Array, Array of Keychain certifiactes.
     */
     func getAboutToBeExpiredCertificates() -> [TrustedCertificate]? {
        
        var certGettingExpiredArr = [TrustedCertificate]()
        //get list of downloaded certificate
        let allDownloadedCertificatesResult = DownloadedCertificateHandler.getTrustedCertificateData()
        
        guard let _allDownloadedCertificatesResult = allDownloadedCertificatesResult , _allDownloadedCertificatesResult.count > 0 else {
            return nil
        }
        
        for downloadedItem in _allDownloadedCertificatesResult {
            //get certificate information from database
            let certInfo = downloadedItem.downloadedCert?.cert
            print("certificate name \((certInfo?.username)!)")
            
            if let _validPercent = certInfo?.validPercent {
                if _validPercent > 0 {
            
            //get the list of certificates about to expire
            let isGettingExpired = calculateCertValidity(expiryTime: (certInfo?.expiryTime)!, downloadTime: (certInfo?.downloadTime)!, validPercentage: certInfo?.validPercent, validTimeValue: certInfo?.validTime)
            
            if isGettingExpired {
                certGettingExpiredArr.append(downloadedItem)
            }
            }
            }
            else {
                //get the list of certificates about to expire
                let isGettingExpired = calculateCertValidity(expiryTime: (certInfo?.expiryTime)!, downloadTime: (certInfo?.downloadTime)!, validPercentage: nil, validTimeValue: certInfo?.validTime)
                
                if isGettingExpired {
                    certGettingExpiredArr.append(downloadedItem)
                }
            }
            
        }

        return certGettingExpiredArr
    }
    
    /**
     This method is used to get list of certificates that have been expired.
     - Returns: A Dictionary, Dictionary of Keychain certifiactes.
     */
    func getExpiredCertificates() -> [TrustedCertificate]? {
        
        var certGettingExpiredArr = [TrustedCertificate]()
        //get list of downloaded certificate
        let allDownloadedCertificatesResult = DownloadedCertificateHandler.getTrustedCertificateData()
        
        guard let _allDownloadedCertificatesResult = allDownloadedCertificatesResult , _allDownloadedCertificatesResult.count > 0 else {
            return nil
        }
        
        for downloadedItem in _allDownloadedCertificatesResult {
            //get certificate information from database
            let certInfo = downloadedItem.downloadedCert?.cert
            print("certificate name \((certInfo?.username)!)")
            //get the list of certificates that have been expired
            let hasbeenExpired = checkIfCertExpired(expiryTime: (certInfo?.expiryTime)!)

            if hasbeenExpired {
                certGettingExpiredArr.append(downloadedItem)
            }
        }
        
        return certGettingExpiredArr
    }
    
    /**
     This method is used to get CRL URL from the certificate in Keychain.
     - Returns: A Dictionary, Dictionary of Keychain certifiactes.
     */
    func getCerDataforCRLURL() -> [TrustedCertificate]? {
        var certDataforCRL = [TrustedCertificate]()
        //list of downloaded certificates in Keychain
        let allDownloadedCertificatesResult = DownloadedCertificateHandler.getTrustedCertificateData()
        guard let _allDownloadedCertificatesResult = allDownloadedCertificatesResult , _allDownloadedCertificatesResult.count > 0 else {
            return nil
        }
        for downloadedItem in _allDownloadedCertificatesResult {
            certDataforCRL.append(downloadedItem)
        }
        return certDataforCRL
    }
 
    /**
     This method is used to get current time of the device.
     - Returns: A String, String value of current time.
     */
     func getCurrentTimeInString() -> String{
        let currentTimeinterval = NSDate().timeIntervalSinceReferenceDate
        let currentNSDate = NSDate(timeIntervalSinceReferenceDate: currentTimeinterval)
        let currentDate = currentNSDate as Date?
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm zz"
        df.locale = NSLocale.current
        return df.string(from: currentDate!)
    }
    
    /**
     This method is used to calculate certificate validity.
     - Parameter expiryTime: the expiryTime of the downloaded certificate.
     - Parameter downloadTime: the downloadTime of the downloaded certificate.
     - Parameter validPercentage: the validPercentage of the downloaded certificate.
     - Returns: A Bool, Bool value determining whether the certificate is about to expire of not.
     */
    func calculateCertValidity(expiryTime: TimeInterval, downloadTime: TimeInterval, validPercentage: Int?, validTimeValue: String?)-> Bool{
        
        var isAboutToBeExpired = false
        let lifetimeOfCert = expiryTime - downloadTime
        var timeToDelete = 0.0
        var percentTime = 0.0
        //let percentTimeInt =  NSString(string: validPercentage).integerValue
        if let _validPercentage = validPercentage {
            percentTime = (Double.init(validPercentage!)*lifetimeOfCert)/100
            let time = lifetimeOfCert - percentTime
            timeToDelete = lifetimeOfCert - time
        }
        else {
            print("CertValidity tag is there" + validTimeValue!)
            let removedLastString = validTimeValue
            let time = String((removedLastString?.dropLast())!)
            timeToDelete = Double(time)!
        }
        let currentTime = NSDate().timeIntervalSinceReferenceDate
        let lifeTimeLeft = expiryTime - currentTime
        
        print("lifeTimeOFCert:::::::: \(lifetimeOfCert) \n PercentageTime:::::\(percentTime)  \n TimeToDelete ::::\(timeToDelete) \n CurrentTime::::\(currentTime) \n lifeTimeLeft:::::\(lifeTimeLeft)")
        
        if (lifeTimeLeft < timeToDelete && lifeTimeLeft > 0) {
            isAboutToBeExpired = true
        }
        print("the certificate is about to expire::::\(isAboutToBeExpired)")
        return isAboutToBeExpired
    }
    
    /**
     This method is used check if the certificate has expired or not.
     - Parameter expiryTime: the expiryTime of the downloaded certificate.
     - Returns: A Bool, Bool value determining whether the certificate has expired or not.
     */
    func checkIfCertExpired(expiryTime: TimeInterval) -> Bool {
        
        var hasbeenExpired = false
        let currentTime = NSDate().timeIntervalSinceReferenceDate
        let lifeTimeLeft = expiryTime - currentTime
        
        print("lifeTimeLeft:::::\(lifeTimeLeft)")
        
        if lifeTimeLeft < 0 {
            hasbeenExpired = true
        }
        print("the certificate has been expired::::\(hasbeenExpired)")
        return hasbeenExpired
    }
}
