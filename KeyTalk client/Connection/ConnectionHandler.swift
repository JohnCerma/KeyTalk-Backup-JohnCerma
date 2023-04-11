//
//  ConnectionHandler.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation

class ConnectionHandler {
    
    //MARK:- Variables
    var lSeriveName = ""
    var username = ""
    var lServerUrl = ""
    var password = ""
    var lChallengeResponseArr : String? = nil
    var bgKeytalkCookie = ""
    var OTP = false
    
    //MARK:- Public Methods
    init (servicename: String,/*username:String,password: String,*/ server:String,challengeResponse:String?){
        self.lSeriveName = servicename
        //self.username = username
        //self.password = password
        self.lServerUrl = server
        self.lChallengeResponseArr = challengeResponse
    }
    
    /**
     This method is used to request server for response.
     - Parameter forURLType: the URL value containing the URLs used to request the KeyTalk server.
     - Parameter serverCookie: the string value containing the server Cookie.
     - Parameter success: the Bool value determining whether the communication was successful or not.
     - Parameter message: the string value containing the message received in response.
     - Parameter responseData: the Data value containing the response data.
     - Parameter ktCookie: the string value containing the server Cookie received after communication.
     */
    func request(forURLType:URLs, serverCookie:String, completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData: Data?,_ ktCookie:String?) -> ()) {
        //makes request to the server
        Connection.makeRequest(request: getRequest(urlType: forURLType,ktCookie: serverCookie), isUserInitiated: false) { (
            success, message,responseData,cookie) in
            if success {
                if let _responseData = responseData {
                    do {
                        //parse the json data and store in dictionary
                        let data = try JSONSerialization.jsonObject(with: _responseData, options: .mutableContainers) as? [String : Any]
                        if let data = data {
                            let status = data["status"] as! String
                            if status == "eoc" {
                                completionHandler(false, "end_of_communication_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
                            }
                            else {
                                completionHandler(true, nil,_responseData,cookie)
                            }
                        }
                        else {
                            completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                        completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
                    }
                } else {
                    completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
                }
            }
            else {
                completionHandler(false, message,nil,cookie)
            }
        }
    }
    
    
    /** Query Common Name customization policy
    
// - Response  will dictate if Common name has to be allowed by the server
//     */
//    func CommonNamecustomizationpolicyRequest(forURLType:URLs, serverCookie:String){
//        Connection.MakeRequestForCommonName(request: getRequest(urlType: URLs, ktCookie:String) )
//        {
//
//    }
    
//    func CommonNamecustomizationpolicyRequest(forURLType:URLs, serverCookie:String, completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData: Data?,_ ktCookie:String?) -> ()) {
//
//        Connection.MakeRequestForCommonName(request: getRequest(urlType: forURLType,ktCookie: serverCookie), isUserInitiated: false) { (success, message,responseData,cookie) in
//            if success {
//                if success {
//                    if let _responseData = responseData {
//                        do {
////                            //parse the json data and store in dictionary
//                            let data = try JSONSerialization.jsonObject(with: _responseData, options: .mutableContainers) as? [String : Any]
////                            if let data = data {
////                                let status = data["status"] as! String
////                                if status == "eoc" {
////                                    completionHandler(false, "end_of_communication_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
////                                }
////                                else {
////                                    completionHandler(true, nil,_responseData,cookie)
////                                }
////                            }
////                            else {
////                                completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
////                            }
//                        }
//                        catch let error {
//                            print(error.localizedDescription)
//                            completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
//                        }
//                    } else {
//                        completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
//                    }
//                }
//                else {
//                    completionHandler(false, message,nil,cookie)
//                }
//            }
//        }
//    }
//
    /**
     This method is used to download the file.
     - Parameter url: the URL value containing the URLs used to download file.
     - Parameter fileurl: the URL value containing the URL of the file path where the file needs to be saved after download.
     - Parameter message: the string value containing the message received in response.
     */
    func downloadFile(url: URL, completionHandler: @escaping (_ fileurl: URL?, _ message: String?) -> ()) {
        let request = URLRequest.init(url: url)
        Connection.downloadFile(request: request) { (fileUrl, message) in
            if let message = message {
                completionHandler(nil, message)
            }
            else {
                completionHandler(fileUrl, nil)
            }
        }
    }
    
    
    /**
     This method is used to get request URL.
     - Parameter urlType: the URL value containing the URL Types needed to request the KeyTalk server.
     - Parameter ktCookie: the string value containing the server Cookie received after communication.
     - Returns: A URLRequest containing the Request URL.
     */
    func getRequest(urlType: URLs,ktCookie:String) -> URLRequest {
        let server = Server(servicename: lSeriveName, username: username, password: password, server: lServerUrl, challengeResponse: lChallengeResponseArr)
        let url = server.getUrl(type: urlType)
        print("Url::::::: \(url)")
        let modelName = Host.current().name! + Host.current().localizedName!
        ////////
        if(((server.getUrl(type: urlType)).description.contains("authentication")) == true)
        {
            
            //encoding the hardware signature required by the server.
            let encodedHwsig = Utilities.sha256(securityString: HWSIGCalc.calcHwSignature())
            //adding the prefix.
            let hwsig = "CS-" + encodedHwsig

            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            if !keytalkCookie.isEmpty {
                //adds cookie in the header of the request.
                request.addValue(keytalkCookie, forHTTPHeaderField: "Cookie")
                request.addValue("identity", forHTTPHeaderField: "Accept-Encoding")
            }

            request.timeoutInterval = 60
     
            
        if(passWordRequired == true)
        {
            components.queryItems = [
                URLQueryItem(name: "service", value: lSeriveName),
                URLQueryItem(name: "caller-hw-description", value: modelName),
                URLQueryItem(name: "USERID", value: userName),
                URLQueryItem(name: "PASSWD", value: Password),
                URLQueryItem(name: "HWSIG", value: hwsig.uppercased()),
                ]
               passWordRequired = false
            }
            
            else if(otpRequired == true) {
            components.queryItems = [
                URLQueryItem(name: "service", value: lSeriveName),
                URLQueryItem(name: "caller-hw-description", value: modelName),
                URLQueryItem(name: "USERID", value:emailValue),
                URLQueryItem(name: "HWSIG", value: hwsig.uppercased()),
            ]
                otpRequired = false
                
                }
             ///////// OTP Support //////
            else if(otpForRequest == true) {
            components.queryItems = [
                URLQueryItem(name: "service", value: lSeriveName),
                URLQueryItem(name: "caller-hw-description", value: modelName),
                URLQueryItem(name: "USERID", value: emailValue),
                URLQueryItem(name: "OTP", value: OTPText),
                URLQueryItem(name: "HWSIG", value: hwsig.uppercased()),
            ]
            otpForRequest = false
        }
        else {
            components.queryItems = [
                URLQueryItem(name: "service", value: lSeriveName),
                URLQueryItem(name: "caller-hw-description", value: modelName),
                URLQueryItem(name: "USERID", value: username),
                URLQueryItem(name: "HWSIG", value: hwsig.uppercased())
            ]
            
        }
            print("CALLER HW DESCRIPTION = \(modelName)" )
            
            var query = components.url!.query
            
            let customAllowedSet =  NSCharacterSet(charactersIn:"!@$*()+").inverted
            query = query?.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
            
            print("query ==", query)
            request.httpBody = Data(query!.utf8)
            
            print("REQUEST IS :::::", request)
            return request
        }
        
        /* POST Certificate request */
          if(((server.getUrl(type: urlType)).description.contains("cert?")) == true)
          {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            var request = URLRequest.init(url: url)
            request.timeoutInterval = 60
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            if !keytalkCookie.isEmpty {
                //adds cookie in the header of the request.
                request.addValue(keytalkCookie, forHTTPHeaderField: "Cookie")
                request.addValue("identity", forHTTPHeaderField: "Accept-Encoding")
            }
            
            if(ALLOWED == true)
            {
                components.queryItems = [
                    URLQueryItem(name: "format", value: "P12"),
                    URLQueryItem(name: "include-chain", value: "false"),
                    URLQueryItem(name: "out-of-band", value: "true"),
                    URLQueryItem(name: "common-name", value: commonName)
                    ]
                //print("request for certificate with ALLOWED is = \(request)")
                
            }
            else{
            
            //format=P12&include-chain=False&out-of-band=True&common-name=\(commonName)"
                components.queryItems = [
                    URLQueryItem(name: "format", value: "P12"),
                    URLQueryItem(name: "include-chain", value: "false"),
                    URLQueryItem(name: "out-of-band", value: "true")
                    ]
            }
            
            var query = components.url!.query
            
            let customAllowedSetForCertCommonName =  NSCharacterSet(charactersIn:" ").inverted
            query = query?.addingPercentEncoding(withAllowedCharacters: customAllowedSetForCertCommonName)
            //query = query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            print("query ==", query)
            request.httpBody = Data(query!.utf8)
            
            print("REQUEST IS :::::", request)
            return request
         }
        
        // Checking the eligibilty for the Common name
        if(((server.getUrl(type: urlType)).description.contains("/public/1.6.1/cn-customization-policy?")) == true)
        {
            var request = URLRequest.init(url: url)
            return request
        }

      
        var request = URLRequest.init(url: url)
        request.timeoutInterval = 60
        request.httpMethod = "GET"
        if !ktCookie.isEmpty {
            request.addValue(ktCookie, forHTTPHeaderField: "Cookie")
            request.addValue("identity", forHTTPHeaderField: "Accept-Encoding")
        }
        return request
    }

    /*
    //- Response  will dictate if Common name has to be allowed by the server
//        */
//    func CommonNamecustomizationpolicyRequest(forURLType:URLs, serverCookie:String), completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData: Data?,_ ktCookie:String?) -> ())
//    {
//        Connection.makeRequest(request: getRequest(urlType: forURLType,ktCookie: serverCookie), isUserInitiated: false) { (success, message,responseData,cookie) in
//           {
//            if success {
//            if let _responseData = responseData {
//                do {
//                    //parse the json data and store in dictionary
//                    let data = try JSONSerialization.jsonObject(with: _responseData, options: .mutableContainers) as? [String : Any]
//                }
//                catch let error {
//                    print(error.localizedDescription)
//                    completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,cookie)
//                }
//            }
//        }
//            else {
//                completionHandler(false, message,nil,cookie)
//            }
//        }
//    }
//
}




