//
//  KCServices.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//
import Cocoa

class KCServices: NSObject {
    
    //MARK:- Class Methods
    /**
     This method is used to get the certificate from Keychain.
     - Returns: A Dictionary, Dictionary of Keychain certifiactes.
     */
    class func getCertificateInfoList() -> [String: [Dictionary<String,AnyHashable>]] {
    
        var certificateDict = [String: [Dictionary<String,AnyHashable>]]()
        var infoArr = [Dictionary<String,AnyHashable>]()

        do {
            
            var status: OSStatus
            //query to get Keychain certificates
            let query: [String: Any] = [
                kSecClass as String : kSecClassCertificate,
                kSecReturnData as String  : kCFBooleanTrue,
                kSecReturnAttributes as String : kCFBooleanTrue,
                kSecReturnRef as String : kCFBooleanTrue,
                kSecMatchLimit as String : kSecMatchLimitAll
            ]
            
            var searchType :CFTypeRef?
            status = SecItemCopyMatching(query as CFDictionary, &searchType)
            
            if status == errSecSuccess {
                //successful
                if let array = searchType as? Array<Dictionary<String,Any>> {
                    var count :Int = 0

                    for item in array {
                        if let Currentdata = item[kSecValueData as String] as? Data {
                            var secCert : SecCertificate?
                            secCert = SecCertificateCreateWithData(kCFAllocatorDefault, Currentdata as CFData)
                            
                            let kcCert = KeychainCertificate.init(certificate: secCert!)
                            
                            var certificateInfoDict = [String:AnyHashable]()
                            
                            //information from the Keychain Certificate
                            let validity = try kcCert.getValidityNotAfter()
                            let validStr = validity!.Value as! TimeInterval
                            let date = validStr
                            let expiryDate = date
                            certificateInfoDict[KEY_CERTIFICATE_DATA] = Currentdata
                            certificateInfoDict[KEY_EXPIRY_DATE] = expiryDate
                            let subjectName = kcCert.SubjectSummary
                            certificateInfoDict[KEY_COMMON_NAME] = subjectName
                            
                            print(subjectName)
                            count += 1

                            certificateInfoDict[KEY_FINGERPRINT] = kcCert.fingerprint()
                            let subjectAlternateNameExtension = try kcCert.getSubjectAlternateName()?.subjectAlternativeName
                            let extendedKeyUsageExtension = try kcCert.getExtendedKeyUsage()?.extendedKeyUsage
                            let crlURL = try kcCert.getIsCRLURLAvailable()?.crlDisributionPointsURL
                            
                            if let _subjectAlternativeName = subjectAlternateNameExtension {
                                if let _extendedKeyUsage = extendedKeyUsageExtension {
                                    if _subjectAlternativeName.contains("@") {
                                        certificateInfoDict[KEY_SUBJECT_ALTERNATE_NAME] = _subjectAlternativeName
                                        certificateInfoDict[KEY_EXTENDED_KEY_USAGE] = _extendedKeyUsage
                                    }
                                }
                            }
                            
                            let serialNumber = try kcCert.getSerialNumber()?.Value as! String
                            certificateInfoDict[KEY_SERIAL_NUMBER] = serialNumber
                            if crlURL != nil {
                                certificateInfoDict[KEY_CRL_URL] = crlURL
                            } else {
                                certificateInfoDict[KEY_CRL_URL] = nil
                            }
                            infoArr.append(certificateInfoDict)
                        }
                    }
                }
            }
        }catch {
            
        }
        
        certificateDict[KEY_KEYTALK_CERTIFICATE] = infoArr
        
        return certificateDict
    }
}

//MARK:- Extension
//to get the differences of the content or elements between arrays
extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
