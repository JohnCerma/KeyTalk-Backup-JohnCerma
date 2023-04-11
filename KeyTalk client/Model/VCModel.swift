//
//  VCModel.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import SwiftUI
//
//protocol OTPDelegate : class {
//    func returnOTP()->Bool
//       // return OTP
//}

class VCModel {
    
    //MARK:- Variables
    var apiService:ConnectionHandler? = nil
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    var isApiSucceed: Bool = false {
        didSet {
            self.successFullResponse?(typeURL)
        }
    }
    ///For handling service and rccd selection.
    var selectedRccd : String? {
        didSet {
            self.updateServiceWithSelectedRCCD?()
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
            self.showChallengeClosure?(typeChallenge,valueChallenge)
        }
    }
    var serverCookie : String? {
        didSet {
            self.setCookie?()
        }
    }
    var certificateData : Data? {
        didSet {
            self.setCertifcateData?()
        }
    }
    var lastMessages : [Dictionary<String,String>]? {
        didSet {
            self.retrieveLastMessage?(lastMessages)
        }
    }
    var addressBook : [Dictionary<String,String>]? {
        didSet {
            self.retrieveAddressBook?(addressBook)
        }
    }
    //type of url for the server comminication.
    var typeURL: URLs = .hello
    //Closure for all the declared variables, called in the parent class.
    var delayTimeClosure: (()->())?
    //type and value of the Challenge
    var valueChallenge:String = String()
    var typeChallenge : ChallengeResult = .PassWordChallenge
    var rccdService:String = ""
    var updateServiceWithSelectedRCCD: (()->())?
    //Closure for all the declared variables, called in the parent class.
    var showChallengeClosure: ((ChallengeResult,String)->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var successFullResponse: ((URLs)->())?
    var downloadRCCD: (()->())?
    var setCookie: (()->())?
    var setCertifcateData: (()->())?
    var retrieveLastMessage: (([[String:String]]?)->())?
    var retrieveAddressBook: (([[String:String]]?)->())?
    var responseData = Data()
    var ktCookie : String = ""
    var OTP = false
    var userFlag = false
    var passwordFlag = false
    var emailFlag = false
   // var onlyEmailValueAfterCertDownload = false
    
    
    
   
    
    //MARK:- Public Methods
    
    /**
     This method is used to request for API service
     - Parameter urlType: The URL value corresponding to the type of URL
     */
    func requestForApiService(urlType: URLs) {
        typeURL = urlType
        self.isLoading = true
     
        apiService?.request(forURLType: urlType, serverCookie: ktCookie) { [self] (success, message, data,cookie)  in
            self.isLoading = false
            if message != nil {
                self.alertMessage = message!
            }
            else {
                self.serverCookie = cookie
                self.responseData = data!
                
                if urlType == .certificate {
                    self.certificateData = data!
                    }
                self.handleResponseAccToUrlType(urlType: urlType)
                }
            }
        
    }
    
//    func requestForApiServiceForCommonName(urlType: URLs) {
//        typeURL = urlType
//        //self.isLoading = true
//        apiService?.CommonNamecustomizationpolicyRequest(forURLType: urlType, serverCookie: ktCookie) { [self] (success, message, data,cookie)  in
//           // self.isLoading = false
////            if message != nil {
////                self.alertMessage = message!
////            }
////            else {
//                self.serverCookie = cookie
//                self.responseData = data!
//
//                if urlType == .certificate {
//                    self.certificateData = data!
//                }
//            self.handleResponseAccToUrlType(urlType: .commonName)
//
//        }
//    }
//
//
    
    
    func requestForDownloadRCCD(downloadUrl: URL, systemfile: @escaping (_ localUrl: URL?) -> ()) {
        self.isLoading = true
        apiService?.downloadFile(url: downloadUrl) { (url, message) in
            self.isLoading = false
            if message != nil {
                self.alertMessage = message!
            }
            else {
                if let url = url {
                    let localFileUrl = self.urlForDownloadedRCCD(systemUrl: url)
                    systemfile(localFileUrl)
                }
            }
        }
    }
    
    func handleResponseAccToUrlType(urlType: URLs) {
        switch urlType {
        case .hello:
            self.isApiSucceed = true
        case .handshake:
            self.isApiSucceed = true
        case .authReq:
            self.handleAuthReq()
        case .authentication:
            self.handleAuthentication()
        case .addressBook:
            self.handleAddressBook()
        case .challenge:
            self.handleAuthentication()
        case .commonNameCase:
            self.handleCommonName()
        case .certificate:
            self.isApiSucceed = true
        case .lastMessage:
            self.retrieveLastMessageForCertificate()
        case .determineTheKindOFCredentials:
            self.parralelAuthReqHandle()
           
            
        }
    }
    
    func urlForDownloadedRCCD(systemUrl: URL) -> URL? {
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        let filePath = docsDirectory.appending("/downloaded.rccd")
        
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        
        do {
            try fileManager.moveItem(atPath: systemUrl.path, toPath: filePath)
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return URL(string: "file://" + filePath)
    }
    
    func getDownloadURLString(aDownloadStr: String) -> String {
        var urlString = aDownloadStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        if !urlString.lowercased().hasSuffix(".rccd") {
            urlString = urlString + ".rccd"
        }
        
        return urlString
    }
    
    
    /**
     This method is used to set the cookie ,in order to send it in the request header for server authentication
     - Parameter cookie: The cookie value coming from the server
     */
    func setKeytalkCookie(cookie:String?) {
        self.serverCookie = cookie
    }

//    func requestData(completion: ((_ : Any ) -> String)) {
//         // the data was received and parsed to String
//        completion("OTP")
//      }
    
    
    //MARK:- Private Methods
    private func handleAuthReq() {
        do {
            
            /* Flushing the emailValue cached in previously downloaded certificate */
            emailValue = ""
            //let dict = try JSONSerialization.jsonObject(with: dataCert, options: .mutableContainers) as? [String : Any]
            let dict = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String : Any]
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
                    
                //////////////////////////////// OTP in Auth -Requirement /////////
                if arr.contains("OTP")
                {
                        toDetermineCredentials = false
                        otpRequired = true
                        emailFlag = true
                        passwordFlag = false
                        
                        NotificationCenter.default.post(name: Notification.Name("OTP-NOTIFICATION"), object: nil)
                       if emailTextFieldValue != "" {
                            emailValue = emailTextFieldValue
                        }
                else {
                        otpRequired = false
                            }
                        }
                    //////////////////////////////// OTP in Auth -Requirement /////////
                    
                if arr.contains("PASSWD")
                {
                        
                        toDetermineCredentials = false
                        passWordRequired = true
                        passwordFlag = true
                        emailFlag = false
                        
                      NotificationCenter.default.post(name: Notification.Name("PASSWORD NOTIFICATION"), object: nil)
                        
                       DispatchQueue.main.async {
                          
                        //Username have a value or return
                        if initialUsername != ""
                             { userName = initialUsername
                                 }
                            else
                            { return
                              }
                        ///Password have a value or else return
                        if password != ""
                            { Password = password
                               }
                            else
                            { return
                                }
                            
                          } // main queue
                }
                        
                    
                else {
                        passWordRequired = false
                    }
                }
            }
            self.isApiSucceed = true
        }
    
        catch let error {
            self.alertMessage = error.localizedDescription
        }
    }
    
    private func handleAuthentication() {
        
        do {
            //gets the dictionary for the server reponse.
           // let dict = try JSONSerialization.jsonObject(with: dataCert, options: .mutableContainers) as? [String : Any]
            let dict = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String : Any]
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
                        
                        print("passwordFlag = \(passwordFlag)")
                        print("emailFlag = \(emailFlag)")
                    
                        if userName == "" && passwordFlag == true {
                            DispatchQueue.main.async {
                                let _ = Utilities.showAlert(aMessageText:"enter_username_password".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))//(aMessageText: "Please enter Username, Password")
                            NotificationCenter.default.post(name: Notification.Name("PASSWORD NOTIFICATION"), object: nil)
                            }
                            break
                        }
                        
                        if Password == "" && passwordFlag == true {
                            DispatchQueue.main.async {
                            let _ = Utilities.showAlert(aMessageText: "enter_username_password".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))//(aMessageText: "Please enter Username, Password")
                                
                            NotificationCenter.default.post(name: Notification.Name("PASSWORD NOTIFICATION"), object: nil)
                            
                            self.passwordFlag = false
                            }
                                break
                            }
                        
                        if emailValue != "" && emailFlag == true
                        {
                            DispatchQueue.main.async {
                           // let _ = Utilities.showAlert(aMessageText: "Please enter a valid email")
                            NotificationCenter.default.post(name: Notification.Name("OTP-NOTIFICATION"), object: nil)
                                
                                }
                                break
                        }
                        /* else block for if once a certificate is downloaded - Next time it will not go until Authentication stage. - If email field have no value and return to break the OTP authentication flow */
                        else {
                            return
                        }
                        
//                        if emailValue == "" && emailFlag == true
//                        {
//                            DispatchQueue.main.async {
//                           // let _ = Utilities.showAlert(aMessageText: "Please enter a valid email")
//                            NotificationCenter.default.post(name: Notification.Name("OTP-NOTIFICATION"), object: nil)
//
//                                }
//                                break
//                        }
                        
                     
                     print("Delay has happened!!!!")
                    //if auth result is delay, then the communication is not successful and the user have to try again after the delay time.
                        
                    
                        ////////////////// Authentication Failed hence Login process should continue again ///
//                        DispatchQueue.main.async {
//                            NotificationCenter.default.post(name: Notification.Name("OTP-NOTIFICATION"), object: nil)
//                        }
                        
                        
                       //////////////////////////////////////////////////////////////////////////////////////////////////////////////
                        
                        
                        //gets the delay time from the reponse.
                        let delay = dictValue[authStatus.lowercased()] as! String

                        //notify the Timer , that the delay have been encountered.
                        self.delayTime = Int(delay)

                        //notify the alert, as a message is recieved.
                        let authenticationFailedTryString = "authentication_failed_try_again_after_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
                        let secString = "seconds_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
                        self.alertMessage = "\(authenticationFailedTryString) \(delay) \(secString)"
                        
                       
                    
                    ////////////////// Authentication Failed hence Login process should continue again ///
                      //  NotificationCenter.default.post(name: Notification.Name("OTP-NOTIFICATION"), object: nil)
                       //////////////////////////////////////////////////////////////////////////////////////////////////////////////
                        
                        
                    case AuthResult.locked.rawValue:
                        //if auth status is locked, then the user is locked at the server side and cannot communicate.
                        //notify the alert, as a message is recieved.
                      if(emailValue == "")
                      {
                        return
                      }
                        self.alertMessage = "user_locked_check_administrator_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
                    case AuthResult.expired.rawValue:
                        //if auth status is expired, then the password has been expired and the user have to update their password.
                        //notify the alert, as a message is recieved.
                        self.alertMessage = "password_expired_update_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
                    case AuthResult.challenge.rawValue:
                        //if auth status is challenge, then the user have to pass all the challenges which have been encountered in the response.
                        
                        //retriving all the challenges encountered in the response in an array.
                        let challengeArr = dictValue["challenges"] as! [[String:Any]]
                        
                        //calls to handle the challenges.
                        self.handleChallenges(aChallengeArr: challengeArr)
                    
                    /////////OTP Support /////
                    case AuthResult.watiForOTP.rawValue:
                     print("OTP Authentication")
                        return

                    DispatchQueue.main.async {
                              
                    NotificationCenter.default.post(name: Notification.Name("OTP-INPUT_REQUIRED-NOTIFICATION"), object: nil)
                    otpForRequest = true
                    }
                        break
                        
                    default:
                        print("Status unrecognised")
                    }
                }
            }
        }
        catch let error {
            //notify the alert, as a error message is recieved.
            self.alertMessage = error.localizedDescription
        }
    }
    
    
    /**
     This method is used to handle all the challenges encountered by the user.
     - Parameter aChallengeArr: An array of challenges encountered.
     */
    private func handleChallenges(aChallengeArr : [[String:Any]]) {
        var challengeDict = [String:Any]()
        //iterating through the challenges array.
        for element in aChallengeArr {
            //eliminating the element from the array, Dictionary type.
            challengeDict = element
        }
        
        //gets the type of challenge encountered.
        guard let challengetype = challengeDict["name"] as? String else {
            return
        }
        //gets the value of challenge encountered.
        guard let _challengeValue = challengeDict["value"] as? String else {
            return
        }
        
        //sets the challenge value.
        self.valueChallenge = _challengeValue.trimmingCharacters(in: .whitespacesAndNewlines)
        switch challengetype {
        case ChallengeResult.PassWordChallenge.rawValue:
            //New Token Challenge.
            self.typeChallenge = ChallengeResult.PassWordChallenge
            //notify that the challenge is encountered.
            self.isChallengeEncountered = true
        default:
            print("Invalid challenge encountered.")
        }
    }
    
    
    private func retrieveLastMessageForCertificate() {
        do {
            ALLOWED = false
            let dict = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String : Any]
            if let dictValue = dict {
                //retrieves the authentication status from the dictionary.
                if let status = dictValue["status"] as? String {//"last-messages"] != nil {
                    if status == "last-messages" {
                    
                    var succDescription = ""
                        ///// Custom last message code  ////
                    DispatchQueue.main.async {
                   
                        guard let messageArr = dictValue ["messages"] as? [Dictionary<String,String>]  else {
                            return
                        }
                        if let messageArr = dictValue ["messages"] as? [Dictionary<String,String>] {
                            self.lastMessages = messageArr
                            
                            for (key, value) in messageArr.enumerated() {
                               print("\(key) \(value)")
                                   print(value)
                               
                                for (key, value) in value
                                {
                                    print(value)
                                    if (value.contains("2021") )
                                        {
                                        print("Not required")
                                                        
                                                      }
                                    else
                                    {
                                        print("Server message has been recorded here")
                                        succDescription = value
                                    }
                                }
                            
                            }
                                
                         //  Utilities.showAlertForLastMessage(aMessageText: succDescription)
                           
                            //askToDownloadOtherCerts();
                            
                            
                        }
                  
                        else {
                            self.lastMessages = [Dictionary<String,String>]()
                        }
                      }
                    }
                }
            
        }
    }catch let error {
            print(error)
            //unable to retrieve the last message
        }
        
    }
    
    private func handleAddressBook() {
        do {
            let dict = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String : Any]
            if let dictValue = dict {
                //retrieves the authentication status from the dictionary.
                if let status = dictValue["status"] as? String {//"last-messages"] != nil {
                    if status == "address-book-list" {
                        //                        guard let messageArr = dictValue ["messages"] as? [Dictionary<String,String>]  else {
                        //                            return
                        //                        }
                        if let addressbookArr = dictValue ["address-books"] as? [Dictionary<String,String>] {
                            self.addressBook = addressbookArr
                        } else {
                            self.addressBook = [Dictionary<String,String>]()
                        }
                    }
                }
            }
            self.isApiSucceed = true

        } catch let error {
            print(error)
            //unable to retrieve the last message
        }
    }
    
    
    /***
 - This method is used to get the desired information for Common Name Request Parameter
    */
    
    private func handleCommonName()
    {
        print("abc")
    }
    
    
    //MARK:- Class Methods
    /**
     This method is used to generate the response URL for the challenge Authentication with the challenge name and their corresponding user response. All the information is appended in the base URL and is send to the server to complete the challenge.
     
     - Parameter aArrDictionary: This is an array of dictionary containing the name of challenge and their reponse in the key value pair format.
     - Returns: A url with appended response from the user.
     */
    class func challengeAuthenticationURL(challenge aArrDictionary:[[String:Any]]) -> String {
        //retrieving the array.
        let arr = aArrDictionary
        
        //encoding the hardware signature required by the server.
        let encodedHwsig = Utilities.sha256(securityString: HWSIGCalc.calcHwSignature())
        
        //adding the prefix.
        let hwsig = "CS-" + encodedHwsig
        
        var passStr = ""
        for dict in arr {
            
            for (key,value) in dict {
                passStr = value as! String
            }
        }
        
        //createa a completed string with all the necessary informations.
        let modelName = Host.current().name! + Host.current().localizedName!
        let tempStr = "?service=\(serviceName)&caller-hw-description=\(modelName)&USERID=\(initialUsername)&PASSWD=\(passStr)&HWSIG=\(hwsig.uppercased())"
        
        //converting it into a valid url format.
        let urlStr = tempStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return urlStr
    }
    
    /**
     This method is used to get the desired information in the request to complete the challenges.
     - Returns: A url string,to complete the challenges.
     */
    class func challengeAuthentication(_ challengeName:String,_ challengeValue:String) -> String {
        let tempChallengeResponse = /*"/rcdp/2.2.0/authentication?responses=*/"\(Utilities.sha256(securityString:challengeName))+\(Utilities.sha256(securityString: challengeValue))"
        let returnChallengeStr = tempChallengeResponse.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return returnChallengeStr!
    }
    
    
    ////////// Route to determine the kind of Credentials /////
    func parralelAuthReqHandle()
    {
        
    }
    
}
 
