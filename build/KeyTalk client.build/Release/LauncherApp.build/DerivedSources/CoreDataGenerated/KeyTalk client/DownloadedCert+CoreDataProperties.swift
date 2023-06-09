//
//  DownloadedCert+CoreDataProperties.swift
//  
//
//  Created by Rinshi Rastogi on 3/4/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DownloadedCert {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadedCert> {
        return NSFetchRequest<DownloadedCert>(entityName: "DownloadedCert")
    }

    @NSManaged public var certChallenge: String?
    @NSManaged public var certCRLURL: String?
    @NSManaged public var certData: Data?
    @NSManaged public var certDownloadTime: Double
    @NSManaged public var certExpiryTime: Double
    @NSManaged public var certFingerPrint: String?
    @NSManaged public var certNotificationShown: Int16
    @NSManaged public var certRCCDName: String?
    @NSManaged public var certServiceName: String?
    @NSManaged public var certServiceUri: String?
    @NSManaged public var certUsername: String?
    @NSManaged public var certValidPer: Int16
    @NSManaged public var certValidTime: String?
    @NSManaged public var commonName: String?
    @NSManaged public var isSMIME: Bool
    @NSManaged public var serialNumber: String?
    @NSManaged public var userInfo: String?

}
