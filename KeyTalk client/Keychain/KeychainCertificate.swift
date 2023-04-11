//
//  KeychainCertificate.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation


@available(OSX 10.13, *)
struct KeychainCertificate
{
    fileprivate let _certificate: SecCertificate
    
    fileprivate static let IOSAppDevelopmentOID         = "1.2.840.113635.100.6.1.2"
    fileprivate static let AppStoreOID                  = "1.2.840.113635.100.6.1.4"
    fileprivate static let MacDevelopmentOID            = "1.2.840.113635.100.6.1.12"
    fileprivate static let MacAppDistributionOID        = "1.2.840.113635.100.6.1.7"
    fileprivate static let MacInstallerDistributionOID  = "1.2.840.113635.100.6.1.8"
    fileprivate static let DeveloperIdOID               = "1.2.840.113635.100.6.1.13"
    fileprivate static let DeveloperIdInstallerOID      = "1.2.840.113635.100.6.1.14"
    
    init(certificate: SecCertificate)
    {
        _certificate = certificate;
        
    }
    
    func fingerprint() -> String {
        let data = SecCertificateCopyData(_certificate) as Data
        
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        print(digest)
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return (hexBytes.joined())
        
    }
    
    var ItemRef: SecKeychainItem
    {
        get { return unsafeBitCast(_certificate, to: SecKeychainItem.self) }
    }
    
    var SubjectSummary : String
    {
        get {
            return SecCertificateCopySubjectSummary(_certificate)! as String
        }
    }
    
    var publicKey : SecKey?
    
    var PublicKeyInfo: OSStatus
    {
        mutating get {
            return SecCertificateCopyPublicKey(_certificate, &publicKey)
        }
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getSubjectName() throws -> KeychainCertificateSubjectName?
    {
        if let property = try ReadProperty(key: kSecOIDX509V1SubjectName)
        {
            return KeychainCertificateSubjectName(property: property)
        }
        
        return nil
    }
    
    func getIssuerName() throws -> KeychainCertificateSubjectName?
    {
        if let property = try ReadProperty(key: kSecOIDX509V1IssuerName)
        {
            return KeychainCertificateSubjectName(property: property)
        }
        
        return nil
    }
    func getSerialNumber() throws -> KeychainCertificateProperty?
    {
        if let property = try ReadProperty(key: kSecOIDX509V1SerialNumber)
        {
            return property
        }
        
        return nil
    }
    
    func getValidityNotAfter
        () throws -> KeychainCertificateProperty?//KeychainCertificateSubjectName?
    {
        if let property = try ReadProperty(key: kSecOIDX509V1ValidityNotAfter)
        {
            return property //KeychainCertificateSubjectName(property: property)
        }
        
        return nil
    }
    
    func getIsCRLURLAvailable() throws -> KeychainCertificatePublicKeyInfo?
    {
        if let property = try ReadProperty(key: kSecOIDCrlDistributionPoints) {
            return KeychainCertificatePublicKeyInfo(property: property)
        }
        return nil
    }
    
    func getValidityNotBefore() throws -> KeychainCertificateSubjectName?
    {
        if let property = try ReadProperty(key: kSecOIDX509V1ValidityNotBefore)
        {
            return KeychainCertificateSubjectName(property: property)
        }
        
        return nil
    }
    
    func getSubjectAlternateName () throws -> KeychainCertificatePublicKeyInfo?
    {
        if let property = try ReadProperty(key: kSecOIDSubjectAltName) {
            return KeychainCertificatePublicKeyInfo(property: property)
        }
        return nil
    }
    
    func getExtendedKeyUsage () throws -> KeychainCertificatePublicKeyInfo?
    {
        if let property = try ReadProperty(key: kSecOIDExtendedKeyUsage) {
            return KeychainCertificatePublicKeyInfo(property: property)
        }
        return nil
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsDevelopment() throws -> Bool
    {
        return try (getIsAppStoreDevelopment() ||
            getIsMacAppStoreDevelopment())
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsProduction() throws -> Bool
    {
        return try (getIsAppStoreDistribution()     ||
            getIsMacAppStoreDistribution()  ||
            getIsMacInstallerDistribution() ||
            getIsDeveloperId()              ||
            getIsDeveloperIdInstaller())
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsAppStore() throws -> Bool
    {
        return try (getIsAppStoreDevelopment() ||
            getIsAppStoreDistribution())
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsMacAppStore() throws -> Bool
    {
        return try (getIsMacAppStoreDevelopment()  ||
            getIsMacAppStoreDistribution() ||
            getIsMacInstallerDistribution())
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsNonMacAppStore() throws -> Bool
    {
        return try (getIsDeveloperId() ||
            getIsDeveloperIdInstaller())
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsAppStoreDevelopment() throws -> Bool
    {
        return try ReadProperty(key: KeychainCertificate.IOSAppDevelopmentOID as CFString) != nil
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsAppStoreDistribution() throws -> Bool
    {
        return try ReadProperty(key: KeychainCertificate.AppStoreOID as CFString) != nil
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsMacAppStoreDevelopment() throws -> Bool
    {
        return try ReadProperty(key: KeychainCertificate.MacDevelopmentOID as CFString) != nil
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsMacAppStoreDistribution() throws -> Bool
    {
        return try ReadProperty(key: KeychainCertificate.MacAppDistributionOID as CFString) != nil
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsMacInstallerDistribution() throws -> Bool
    {
        return try ReadProperty(key: KeychainCertificate.MacInstallerDistributionOID as CFString) != nil
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsDeveloperId() throws -> Bool
    {
        return try ReadProperty(key: KeychainCertificate.DeveloperIdOID as CFString) != nil
    }
    
    // TODO: this should be a computed property, but they can't throw (yet)
    func getIsDeveloperIdInstaller() throws -> Bool
    {
        return try ReadProperty(key: KeychainCertificate.DeveloperIdInstallerOID as CFString) != nil
    }
    
    fileprivate func ReadProperty(key: CFString) throws -> KeychainCertificateProperty?
    {
        let keys: [CFString] = [ key ]
        var unmanagedErrorOpt: Unmanaged<CFError>?
        let certValuesAnyOpt = withUnsafeMutablePointer(to: &unmanagedErrorOpt) { SecCertificateCopyValues(_certificate, keys as CFArray?, $0) }
        
        if let unmanagedError = unmanagedErrorOpt
        {
            let cfError : CFError = unmanagedError.takeRetainedValue()
            
            throw make_error(cfError)
        }
        
        if let certValuesAny = certValuesAnyOpt
        {
            let certValuesNS = certValuesAny as NSDictionary
            let certValues = certValuesNS as! [String: AnyObject]
            let valueAnyOpt = certValues[key as String]
            
            if let valueAny = valueAnyOpt
            {
                if let valueNS = valueAny as? NSDictionary
                {
                    if let value = valueNS as? [String: AnyObject]
                    {
                        return KeychainCertificateProperty(entry: value)
                    }
                }
            }
        }
        
        return nil
    }
}

struct KeychainCertificatePublicKeyInfo
{
    fileprivate let _properties : [KeychainCertificateProperty]
    init?(property: KeychainCertificateProperty) {
        var subjectValueArray :[NSDictionary] = [[:]]
        var lNSDictionary :[String:Any] = [:]
        lNSDictionary[kSecPropertyKeyLabel as String] = property.Label
        lNSDictionary[kSecPropertyKeyLocalizedLabel as String] = property.LocalizedLabel
        lNSDictionary[kSecPropertyKeyValue as String] = property.Value
        
        subjectValueArray.append(lNSDictionary as NSDictionary)
        _properties = subjectValueArray.map {
            let subjectItem = $0 as! [String: AnyObject]
            return KeychainCertificateProperty(entry: subjectItem)
        }
    }
    var subjectAlternativeName : String {
        get
        {
            if let _ = FindString(label: kSecOIDSubjectAltName)  {
                return FindString(label: kSecOIDSubjectAltName)!
            } else {
                return "NO SUBJECT ALTERNATE NAME FOUND"
            }
        }
    }
    
    var extendedKeyUsage: String {
        get {
            if let _ =  Find(label: kSecOIDExtendedKeyUsage) {
                return FindString(label: kSecOIDExtendedKeyUsage)!
            } else {
                return "NO EXTENDED KEY USAGE FOUND"
            }
        }
    }
    var crlDisributionPointsURL: String {
        get {
            if let _ =  FindString(label: kSecOIDCrlDistributionPoints) {
                return FindString(label: kSecOIDCrlDistributionPoints)!
            } else {
                return "NO CRL URL FOUND"
            }
        }
    }
    
    fileprivate func FindString(label: CFString) -> String?
    {
        if let property = Find(label: label)
        {
            let value = property.Value as? NSArray
            var returnValueString = ""
            if let _value = value {
                if let  array = NSArray(array: _value) as? [[String: Any]] {
                    guard let returnValueObject = array[1]["value"] else {
                        return nil
                    }
                    returnValueString = String(describing: returnValueObject)
                }
            }
            return returnValueString
        }
        
        return nil
    }
    fileprivate func Find(label: CFString) -> KeychainCertificateProperty?
    {
        let labelString = label as String
        let foundIndexOpt = _properties.index { $0.Label == labelString }
        
        if let foundIndex = foundIndexOpt
        {
            return _properties[foundIndex]
        }
        
        return nil
    }
    
}

struct KeychainCertificateSubjectName
{
    fileprivate let _properties: [KeychainCertificateProperty]
    
    init?(property: KeychainCertificateProperty)
    {
        var subjectValueArray :[NSDictionary] = [[:]]
        var lNSDictionary :[String:Any] = [:]
        lNSDictionary[kSecPropertyKeyLabel as String] = property.Label
        lNSDictionary[kSecPropertyKeyLocalizedLabel as String] = property.LocalizedLabel
        lNSDictionary[kSecPropertyKeyValue as String] = property.Value
        
        subjectValueArray.append(lNSDictionary as NSDictionary)
        _properties = subjectValueArray.map {
            let subjectItem = $0 as! [String: AnyObject]
            return KeychainCertificateProperty(entry: subjectItem)
        }
    }
    
    var OrganizationName: String?
    {
        get
        {
            return FindString(label: kSecOIDOrganizationName)
        }
    }
    
    var CommonName: String?
    {
        get
        {
            return FindString(label: kSecOIDCommonName)
        }
    }
    
    var OrganizationalUnitName: String?
    {
        get
        {
            return FindString(label: kSecOIDOrganizationalUnitName)
        }
    }
    
    fileprivate func FindString(label: CFString) -> String?
    {
        if let property = Find(label: label)
        {
            if let value = property.Value as? String
            {
                return value
            }
        }
        
        return nil
    }
    
    fileprivate func Find(label: CFString) -> KeychainCertificateProperty?
    {
        let labelString = label as String
        let foundIndexOpt = _properties.index { $0.Label == labelString }
        
        if let foundIndex = foundIndexOpt
        {
            return _properties[foundIndex]
        }
        
        return nil
    }
}

struct KeychainCertificateProperty
{
    fileprivate let _entry: [String: AnyObject]
    
    init(entry: [String: AnyObject])
    {
        _entry = entry;
    }
    
    var Label: String
    {
        get
        {
            if (_entry[kSecPropertyKeyLabel as String] != nil) {
                return _entry[kSecPropertyKeyLabel as String] as! String
            } else {
                return "no value found"
            }
        }
    }
    
    var LocalizedLabel: String
    {
        get
        {
            return _entry[kSecPropertyKeyLocalizedLabel as String] as! String
        }
    }
    
    var Value: AnyObject
    {
        get
        {
            return _entry[kSecPropertyKeyValue as String]!
        }
    }
}

