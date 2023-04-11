//
//  Providers.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation

//MARK:- Structures
//MARK:-
struct UserModel: Codable {
    let ConfigVersion: String
    let LatestProvider: String
    let LatestService: String
    var Providers: [Provider]
    
}

//MARK:-
struct Provider: Codable {
    let Name: String
    let ContentVersion: Double
    let Server: String
    let LogLevel: String
    let CAs: [String]
    var Services: [Service]
    var imageLogo: Data? = nil
}

//MARK:-
struct Service: Codable {
    let Name: String
    let CertFormat: String
    let CertChain: Bool
    let Uri: String?
    let CertValidPercent: Int?
    let CertValidity: String?
    var Users: [String]?
}

//MARK:-
struct P12Certificate {
    
    var downloadTime: TimeInterval
    var expiryTime: TimeInterval
    var data: Data
    var validPercent: Int?
    var validTime: String?
    var fingerPrint: String
    var associatedServiceName : String
    var username: String
    var isSMIME: Bool
    var serviceUri: String
    var challenge : String?
    var notificationShown: Int
    var serialNumber : String
    var commonName : String
    var crlURL : String?
}

//MARK:-
struct rccd {
    var name : String
    var imageData: Data
    var users: [UserModel]
}

//MARK:-
struct DownloadedCertificate {
    var rccdName : String?
    var user : [UserModel]
    var cert : P12Certificate?
}

//MARK:-
struct TrustedCertificate {
    var downloadedCert: DownloadedCertificate?
}

//MARK:-
struct ChallengeUserResponse : Codable {
    var challenges : [ChallengeModel]?
}

//MARK:-
struct ChallengeModel: Codable {
    var message : String
    var response : String
}

//MARK:-
struct CRLCheckFrequency: Codable {
    var timetoCheck: Double
    var crlFrequencySelected: Double
    var crlKey: String
}

//MARK:-
struct StartAtLoginEnabled: Codable {
    var isStartAtLoginEnabled: Bool
    var loginKey: String
    var permissionKey: String
    var hasPermissionBeenGiven: Bool
}

//MARK:-
struct CusomiztionPolicy: Decodable {
    var status: String
    var policy: String
}
