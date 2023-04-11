//
//  Connection.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation

class Connection: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    static private var keyTalkCookie = ""
    
    static private let shared = Connection()
    static private var sUrlSession: URLSession? = nil
    class private func urlSession() -> URLSession {
        if (sUrlSession == nil) {
            #if false
            sUrlSession = URLSession.shared
            #else
            let urlSessionConfiguration = URLSessionConfiguration.default
            urlSessionConfiguration.urlCache = nil
            
            sUrlSession = URLSession(configuration: urlSessionConfiguration, delegate: Connection.shared, delegateQueue: nil)
            #endif
        }
        
        return sUrlSession!
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        print(challenge.protectionSpace.host)
       
        if  challenge.protectionSpace.protocol == "https" {
           
            let trust = challenge.protectionSpace.serverTrust
            if let serverTrust = trust {
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
                if let _certificate = certificate {
                    let credential: URLCredential = URLCredential(trust: serverTrust)
                    //the server is trusted since the certificates matched.
                    completionHandler(.useCredential, credential)
                } else {
                    //if unable get the certificate, then ends the server authentication.
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            }
        } else {
            //ends the server authentication.
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    class func hitService(urlRequest: URLRequest,isUserInitiated:Bool, completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData: Data?,_ ktCookie: String?) -> Void) -> Void {
        Connection.urlSession().dataTask(with: urlRequest) { (data, response, error) in
            
            var tempCookie = ""
            var logStr = urlRequest.url!.absoluteString
            if logStr.contains("&HWSIG") {
                logStr = logStr.components(separatedBy: "&PASSWD")[0]
            }
            
            if let lTempError = error {
                logStr = logStr + "," + lTempError.localizedDescription
                print(lTempError.localizedDescription)
                completionHandler(false, lTempError.localizedDescription, nil,nil)
            }
            else {
                let tempHttpResponse = response as! HTTPURLResponse
                print("Status:\n\(tempHttpResponse.statusCode)")
                print("Headers:::\n\(tempHttpResponse.allHeaderFields)")
                
                if tempHttpResponse.statusCode == 200 {
                    let dict = tempHttpResponse.allHeaderFields
                    if dict["Set-Cookie"] != nil {
                        tempCookie = dict["Set-Cookie"] as! String

                    }
                    if isUserInitiated {
                        dataCert = data!
                    } else {
                    }
                    
                   
                    
                    let str = String.init(data: data!, encoding: .utf8)
                    print("ResponseString:::\n\(str ?? "")")
                    logStr = logStr + "," + (str ?? "")
                    
                    //////////// Common name customization policy /////
                    if((urlRequest.url?.description.contains("/public/1.6.1/cn-customization-policy?") == true)) {
                    let chkCustomize:CusomiztionPolicy = try! JSONDecoder().decode(CusomiztionPolicy.self, from: data!)
                    print(chkCustomize.status)
                        print(chkCustomize.policy)
                        
                        if(chkCustomize.policy == "ALLOWED")
                        {
                            print("ALLOWED is TRUE")
                            ALLOWED = true
                        }
                    }
                    //////////// Common name customization policy /////
                    
                    completionHandler(true, nil,data!,tempCookie)
                }
                else {
                    completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,nil)
                }
            }
            }.resume()
    }
    
    class func makeRequest(request: URLRequest, isUserInitiated: Bool ,completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData : Data?,_ ktCookie : String?) -> Void) {
        
        hitService(urlRequest: request, isUserInitiated: isUserInitiated) { (success, message, data,cookie)  in
            if success {
                completionHandler(true, nil, data,cookie)
            }
            else {
                completionHandler(false, message,nil,cookie)
            }
        }
    }
   
    
//    class func hitServiceForCommonName(urlRequest: URLRequest, completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData: Data?,_ ktCookie: String?) -> Void) -> Void {
//
//        print("Come to hitServiceForCommonName")
//
//        Connection.urlSession().dataTask(with: urlRequest) { (data, response, error) in
//
//            var logStr = urlRequest.url!.absoluteString
//
//            if let lTempError = error {
//                print("HIT SERVICE FOR CPMMON NAME HAS COME TO THE ERROR BLOCK")
//                logStr = logStr + "," + lTempError.localizedDescription
//                print(lTempError.localizedDescription)
//                //completionHandler(false, lTempError.localizedDescription, nil,nil)
//            }
//            else {
//                let tempHttpResponse = response as! HTTPURLResponse
//                print("Status:\n\(tempHttpResponse.statusCode)")
//                print("Headers:::\n\(tempHttpResponse.allHeaderFields)")
//
//                if tempHttpResponse.statusCode == 200 {
//                    let dict = tempHttpResponse.allHeaderFields
//                //    if dict["Set-Cookie"] != nil {
//                  //      tempCookie = dict["Set-Cookie"] as! String
//
//                    //}
//                    //if isUserInitiated {
//                      //  dataCert = data!
//                    //} else {
//                    //}
//
//                    let str = String.init(data: data!, encoding: .utf8)
//                    print("ResponseString:::\n\(str ?? "")")
//                    logStr = logStr + "," + (str ?? "")
//                    //completionHandler(true, nil,data!,tempCookie)
//                }
////                else {
////                    completionHandler(false, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String),nil,nil)
////                }
//            }
//            }.resume()
//    }
//
    
    //class func CommonNameMakeRequest(request: URLRequest, completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData : Data?) -> Void) {
    
    //class func CommonNameMakeRequest(request: URLRequest, isUserInitiated: Bool ,completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData : Data?) -> Void) {
        
//    class func MakeRequestForCommonName(request: URLRequest, isUserInitiated: Bool ,completionHandler: @escaping (_ success: Bool, _ message: String?,_ responseData : Data?,_ ktCookie : String?) -> Void) {
//     
//        hitServiceForCommonName(urlRequest: request) { (success, message, data,cookie)  in
//            if success {
//                completionHandler(true, nil, data, cookie)
//            }
//            else {
//                completionHandler(false, message,nil, cookie)
//            }
//            
//            print("Coming to the hit Service outside")
//        }
//    }
//   
    
    
    
    class func downloadFile(request: URLRequest, completionHandler: @escaping (_ fileUrl: URL?, _ message: String?) -> ()) {
        urlSession().downloadTask(with: request) { (systemUrl, response, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == 200 {
                    completionHandler(systemUrl, nil)
                }
                else {
                    completionHandler(nil, "something_went_wrong_try_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
                }
            }
            }.resume()
    }
}



