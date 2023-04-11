//
//  ExpiredCertificateHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//
/**
import Foundation
import AppKit
import Cocoa

class ExpiredCertificateHandler : NSObject {
    
    var apiService : ConnectionHandler?
    
    var isApiSucceed: Bool = false {
        didSet {
            self.successFullResponse?(typeURL)
        }
    }
    
    //variabe notified when delay is recieved.
    var delayTime : Int? {
        didSet {
            self.delayTimeClosure?()
        }
    }
    
    //variable notified when challenge is recieved.
    var isChallengeEncountered:Bool? {
        didSet {
            //self.showChallengeClosure?(typeChallenge,valueChallenge)
            self.requestForApiService(urlType: .challenge)
        }
    }
    var serverCookie : String? {
        didSet {
            self.setCookieClosure?()
        }
    }
    
    //type of url for the server comminication.
    var typeURL: URLs = .hello
    
    //Closure for all the declared variables, called in the parent class.
    var delayTimeClosure: (()->())?
    
    //type and value of the Challenge
    var valueChallenge:String = String()
    var typeChallenge : ChallengeResult = .PassWordChallenge
    
    //Closure for all the declared variables, called in the parent class.
    var showChallengeClosure: ((ChallengeResult,String)->())?
    var successFullResponse: ((URLs)->())?
    var setCookieClosure: (()->())?

    let mHomeDirectory = FileManager.default.homeDirectoryForCurrentUser

    var expiredCertificate : TrustedCertificate?
    var bgResponseData = Data()
    var ktServerCookie: String = ""
    var mCertiModel : DownloadedCertificate? = nil
    
    init(certificate : TrustedCertificate) {
        self.expiredCertificate = certificate
    }
    
    func startAuthenticationProcess () {
        
        //deletes the expired certificate from the keychain.
        CertificateHandler.deleteCertificates(fingerprint: (expiredCertificate?.downloadedCert?.cert?.fingerPrint)!)
        
        setUpModel()
        
        bgDataCert = Data()
        bgkeytalkCookie = ""

        //sets the connection class, with all the prerequisite informations.
        //apiService = ConnectionHandler(servicename: (expiredCertificate?.downloadedCert?.cert?.associatedServiceName)!, username: (expiredCertificate?.downloadedCert?.cert?.username)!, server: Utilities.returnValidServerUrl(urlStr: (expiredCertificate?.downloadedCert?.user[0].Providers[0].Server)!), challengeResponse: expiredCertificate?.downloadedCert?.cert?.challenge)
       
        //saving the ceriticate instance.
        mCertiModel = DownloadedCertificate(rccdName: expiredCertificate?.downloadedCert?.rccdName, user: (expiredCertificate?.downloadedCert?.user)!, cert: nil)
       
        //calls for hello hit
        requestForApiService(urlType: .hello)
    }
    
    func requestForApiService(urlType: URLs) {
        typeURL = urlType
        apiService?.request(forURLType: urlType,serverCookie: ktServerCookie) { [self] (success, message, responseData, cookie) in
            print("urltype::::::\(urlType)   message:::::\(String(describing: message))  issuccess:::\(success) responseData:::\(String(describing: responseData)) cookie:::::\(String(describing: cookie))")
            if message != nil {
                // self.alertMessage = message!
            }
            else {
                self.setCookie(cookie: cookie)
                self.bgResponseData = responseData!
                self.handleResponseAccToUrlType(urlType: urlType)
            }
        }
    }
    
    /**
     This method is used to handle the api request to the server according to the URL.
     The URL type is used to notify that the server communication is successful for that URL and to call the next sequential server request.
     
     - Parameter typeUrl: Type of URL for server communication.
     */
    private func handleAPIs(typeUrl: URLs) {
        switch typeUrl {
        case .hello:
            requestForApiService(urlType: .handshake)
        case .handshake:
            requestForApiService(urlType: .authReq)
        case .authReq:
            requestForApiService(urlType: .authentication)
        case .authentication:
            requestForApiService(urlType: .certificate)
        case .challenge:
            requestForApiService(urlType: .certificate)
        case .certificate:
            downloadCertificate()
        }
    }
    
    //Set up the VCModel instances for the callbacks, So that when the variables will set then the appropriate actions can be taken.
    private func setUpModel() {
        //set up the challenge closure, when the challenge is encountered.
        showChallengeClosure = {[weak self] (challengeType,challengeValue) in
            DispatchQueue.main.async {
                //calls the server to complete the challenge.
                self?.requestForApiService(urlType: .challenge)
            }
        }
        
        setCookieClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let cookie = self?.serverCookie {
                   self?.setCookie(cookie: cookie)
                }
            }
        }
        
        successFullResponse = { [self] (urlType) in
            DispatchQueue.main.async {
                self.handleAPIs(typeUrl: urlType)
            }
        }
    }
    
    /**
     This method will retrieve the cookie and sets it into a local variable for further handling.
     */
    private func setCookie(cookie:String?) {
        guard let _cookie = cookie , !_cookie.isEmpty else {
            return
        }
        //stores the cookie.
        ktServerCookie = _cookie
    }
        
    /**
     This method is used to download the certificate after the authentication is completed.
     */
    
    private func downloadCertificate() {
        do {
            
            //json model of the selected service
            let expiredCertServerUrlStr = expiredCertificate?.downloadedCert?.user[0].Providers[0].Server
            
            //json-serialization of the model
            let dict = try JSONSerialization.jsonObject(with: bgResponseData, options: []) as? [String:Any]
            
            //gets the status of the response.
            if let status = dict!["status"] as? String {
               
                //if auth status is cert.
                if status == "cert" {
                    
                    //gets the url from which the certificate needs to be downloaded.
                    guard let certUrlStr = dict!["cert-url-templ"] as? String,certUrlStr.count > 0 else{
                        AppDelegate.init().logger.write("\n Time::::::: \(AppDelegate.init().getTimeStamp()),            cannot retrieve the certificate url from the response")
                        return
                    }
                   
                    //retrieving password of the p12 certificate
                    let passcode = ktServerCookie.components(separatedBy: "=")[1]
                    let index = passcode.index(passcode.startIndex, offsetBy: 30)
                    let subString = passcode[..<index]
                    var serverString = expiredCertServerUrlStr
                    if (serverString?.contains("https://"))! {
                        serverString = serverString?.components(separatedBy: "//")[1]
                    }
                    
                    if certUrlStr.count > 0 {
                        //creating a valid url withe service host url and the certificate url.
                        let tempURLString = certUrlStr.replacingOccurrences(of: "$(KEYTALK_SVR_HOST)", with: serverString!)
                        let certURL = URL(string: tempURLString)
                        
                        //filename of the certificate
                        let fileName = (certURL?.lastPathComponent)! + ".p12"
                        
                        //destination path to store the downloaded certificate
                        let destinationPath = mHomeDirectory.appendingPathComponent("DownloadedCertificates", isDirectory: true)
                       
                        //create directory for downloaded certificates
                        try FileManager.default.createDirectory(atPath: destinationPath.path, withIntermediateDirectories: true, attributes: nil)
                        let filePath = destinationPath.appendingPathComponent(fileName, isDirectory: false)
                       
                        //download the certificate
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig)
                        let request = try! URLRequest(url: certURL!)
                        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                               
                                //Certificate downloaded successfully
                                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                    print("Success: \(statusCode)")
                                    do {
                                        //check if file already exists
                                        if FileManager.default.fileExists(atPath: filePath.path){
                                            //remove item from path
                                            try FileManager.default.removeItem(atPath: filePath.path)
                                        }
                                        //copy downloaded file to the path
                                        try FileManager.default.copyItem(atPath: tempLocalUrl.path, toPath: filePath.path)
                                        let lCertificateLoader = CertificateLoader()
                                        
                                        //load p12 certificate and store it in Keychain
                                        lCertificateLoader.loadPKCSCertificate(path: filePath.path, p12Password: String(subString), isUserInitiated: false, certificateModel: self.mCertiModel, aServiceUsername: (self.expiredCertificate?.downloadedCert?.cert?.username)!, aServiceName: (self.expiredCertificate?.downloadedCert?.cert?.associatedServiceName)!)
                                    
                                    }catch{
                                        AppDelegate.init().logger.write("\n Time::::::: \(AppDelegate.init().getTimeStamp()),            could not download certificate. ")
                                    }
                                }
                            } else {
                                AppDelegate.init().logger.write("\n Time::::::: \(AppDelegate.init().getTimeStamp()),            could not download certificate due to:  \(String(describing: error?.localizedDescription))")
                            }
                        }
                        task.resume()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        AppDelegate.init().logger.write("\n Time::::::: \(AppDelegate.init().getTimeStamp()),            could not initiate certificate downloading, resetting every parameter.")
                    }
                }
            }
        }
        catch {
            
        }
    }
    
    private func handleResponseAccToUrlType(urlType: URLs) {
        switch urlType {
        case .hello:
            self.isApiSucceed = true
        case .handshake:
            self.isApiSucceed = true
        case .authReq:
            self.handleAuthReq()
        case .authentication:
            self.handleAuthentication()
        case .challenge:
            self.handleAuthentication()
        case .certificate:
            self.isApiSucceed = true
        }
    }
    
    private func handleAuthReq() {
        do {
            let dict = try JSONSerialization.jsonObject(with: bgResponseData, options: .mutableContainers) as? [String : Any]
            if let dictValue = dict {
                if dictValue["credential-types"] != nil {
                    let arr = dictValue["credential-types"] as! [String]
                    if arr.contains("HWSIG") {
                        hwsigRequired = true
                        let formula = dictValue["hwsig_formula"] as? String
                        if let formula = formula {
                            HWSIGCalc.saveHWSIGFormula(formula: formula)
                        }
                    }
                    else {
                        hwsigRequired = false
                    }
                }
            }
            self.isApiSucceed = true
        }
        catch {}
    }
    
    private func handleAuthentication() {
        do {
            //gets the dictionary for the server reponse.
            let dict = try JSONSerialization.jsonObject(with: bgResponseData , options: .mutableContainers) as? [String : Any]
            if let dictValue = dict {
                //retrieves the authentication status from the dictionary.
                if dictValue["auth-status"] != nil {
                    guard let authStatus = dictValue["auth-status"] as? String else {
                        return
                    }
                    
                    //since the auth status can be of different types, so handle on the basis of Auth Result.
                    switch authStatus {
                    case AuthResult.ok.rawValue:
                        //if the auth result is OK, then the communication is successful and the certificate can be retrieved.
                        self.isApiSucceed = true
                    case AuthResult.delayed.rawValue:
                        //if auth result is delay, then the communication is not successful and the user have to try again after the delay time.
                        
                        //gets the delay time from the reponse.
                        let delay = dictValue[authStatus.lowercased()] as! String
                        
                        //notify the Timer , that the delay have been encountered.
                        self.delayTime = Int(delay)

                    case AuthResult.locked.rawValue:
                        //if auth status is locked, then the user is locked at the server side and cannot communicate.
                        print("locked")
                    case AuthResult.expired.rawValue:
                        //if auth status is expired, then the password has been expired and the user have to update their password.
                        //notify the alert, as a message is recieved.
                        //self.alertMessage = "Password is expired. Please update your password."
                        print("expired")
                    case AuthResult.challenge.rawValue:
                        //if auth status is challenge, then the user have to pass all the challenges which have been encountered in the response.
                        
                        //retriving all the challenges encountered in the response in an array.
                        //let challengeArr = dictValue["challenges"] as! [[String:Any]]
                        
                        //notifies , that challenge is encountered.
                        self.isChallengeEncountered = true
                        
                        //calls to handle the challenges.
                        //self.handleChallenges(aChallengeArr: challengeArr)
                    default:
                        print("Status unrecognised")
                    }
                }
            }
        }
        catch {}
    }
    
//    /**
//     This method is used to handle all the challenges encountered by the user.
//     - Parameter aChallengeArr: An array of challenges encountered.
//     */
//    private func handleChallenges(aChallengeArr : [[String:Any]]) {
//        var challengeDict = [String:Any]()
//        //iterating through the challenges array.
//        for element in aChallengeArr {
//            //eliminating the element from the array, Dictionary type.
//            challengeDict = element
//        }
//
//        //gets the type of challenge encountered.
//        guard let challengetype = challengeDict["name"] as? String else {
//            return
//        }
//        //gets the value of challenge encountered.
//        guard let _challengeValue = challengeDict["value"] as? String else {
//            return
//        }
//
//        //sets the challenge value.
//        self.valueChallenge = _challengeValue.trimmingCharacters(in: .whitespacesAndNewlines)
//        switch challengetype {
//        case ChallengeResult.PassWordChallenge.rawValue:
//            //New Token Challenge.
//            self.typeChallenge = ChallengeResult.PassWordChallenge
//            //notify that the challenge is encountered.
//            self.isChallengeEncountered = true
//        default:
//            print("Invalid challenge encountered.")
//        }
//    }
//
//    /**
//     This method is used to generate the response URL for the challenge Authentication with the challenge name and their corresponding user response. All the information is appended in the base URL and is send to the server to complete the challenge.
//
//     - Parameter aArrDictionary: This is an array of dictionary containing the name of challenge and their reponse in the key value pair format.
//     - Returns: A url with appended response from the user.
//     */
//    class func challengeAuthenticationURL(challenge aArrDictionary:[[String:Any]]) -> String {
//        //retrieving the array.
//        let arr = aArrDictionary
//
//        //encoding the hardware signature required by the server.
//        let encodedHwsig = Utilities.sha256(securityString: HWSIGCalc.calcHwSignature())
//
//        //adding the prefix.
//        let hwsig = "CS-" + encodedHwsig
//
//        var passStr = ""
//        for dict in arr {
//
//            for (key,value) in dict {
//                passStr = value as! String
//            }
//        }
//
//        //createa a completed string with all the necessary informations.
//        let modelName = Host.current().name! + Host.current().localizedName!
//        let tempStr = "?service=\(serviceName)&caller-hw-description=\(modelName)&USERID=\(username)&PASSWD=\(passStr)&HWSIG=\(hwsig.uppercased())"
//
//        //converting it into a valid url format.
//        let urlStr = tempStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        return urlStr
//    }
}
 */
