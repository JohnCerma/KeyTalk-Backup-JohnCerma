//
//  Utilities.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import CoreData
import AppKit
import SSZipArchive

class Utilities {
    
    //MARK:- Static Variables
    static let sHomeDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/KeyTalk client"
    static var MoveInProgress = false
    static var count = 2
    var logger = Logger()
    


    //MARK:- Class Methods
    
    /**
     This method is used to show alert to the user.
     - Parameter aMessageText: the String value containing the text on the alert.
     */
    class func showAlert(aMessageText: String){
        let alert: NSAlert = NSAlert()
        alert.messageText = aMessageText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        DispatchQueue.main.async {
            alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            
        }
    }
    
    class func showAlert(aMessageText: String, aInformativeText: String){
        let alert: NSAlert = NSAlert()
        alert.messageText = aMessageText
        alert.informativeText = aInformativeText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        DispatchQueue.main.async {
            alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            
        }
    }
    
    /**
     This method is used to show alert to the user.
     - Parameter aMessageText: the String value containing the text on the alert.
     - Parameter tag: the String value containing the text on the alert.
     */
    class func showAlert(aMessageText: String?, tag: Int) -> String? {
        var strValue: String = ""
        if tag == 0 {
            if let strValue1 = showURLAlert(aMessageText: aMessageText) {
                strValue = strValue1
            }
            
        } else if tag == 1 {
            strValue = showPopupAlert(aMessageText: aMessageText)!
        }
//        else if tag == 2 {
//            strValue = showInformativeAlert(aMessageText: aMessageText)!
//        }
        return strValue
    }
    
    class func showAlertforAppStart(aMessageText: String?, tag: Int) -> String? {
        var strValue: String = ""
        if tag == 0 {
            if let strValue1 = showURLAlert(aMessageText: aMessageText) {
                strValue = strValue1
            }
            
        } else if tag == 1 {
            strValue = showPopupAlert(aMessageText: aMessageText)!
        }
//        else if tag == 2 {
//            strValue = showInformativeAlert(aMessageText: aMessageText)!
//        }
        //close any old instance of the app
        NSApplication.shared.mainWindow?.close()
        return strValue
    }
    
    class func showPopupAlert(aMessageText: String?) -> String? {
       
        let alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
            /// To balance Cancel
        //alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn
        //////   To balance Cancel
        
        alert.alertStyle = NSAlert.Style.warning
        alert.runModal()
        return aMessageText
    }
    
    
    ////////////    New Requirement for the last Server Message clock to close the Client Application Window   ////
    class func showAlertForLastMessage(aMessageText: String?) //-> String
    {
          
        let alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        alert.informativeText = aMessageText!
            alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
            //alert.addButton(withTitle:"".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
            alert.alertStyle = NSAlert.Style.warning
            
        if alert.runModal().rawValue == 1000 {
            
            NSApplication.shared.windows[0].close()
        }
        
        //NSApplication.shared.windows[0].close()
        //alert.runModal()
        
       // return aMessageText!
        }
    ////////////    New Requirement for the last Server Message clock to close the Client Application Window   ////
    
    ////////////    New Requirement if the Certificate already exists   ////
    class func showAlertForCertificateAlreadtExistsMessage(aMessageText: String?) //-> String
    {
          
        let alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        alert.informativeText = aMessageText!
            alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
            //alert.addButton(withTitle:"".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
            alert.alertStyle = NSAlert.Style.warning
            
        if alert.runModal().rawValue == 1000 {
            
            NSApplication.shared.windows[0].close()
        }
        
        //NSApplication.shared.windows[0].close()
        //alert.runModal()
        
       // return aMessageText!
        }

    
    
    
    ////////////    New Requirement if the Certificate already exists   ////
    
    
    

    ///////////// for OTP /////
    
    class func showPopupAlertOTP(aMessageText: String?) -> String? {
        let alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle:"".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.alertStyle = NSAlert.Style.warning
        alert.runModal()
        return aMessageText
    }
    
    ///////////// for OTP ////
    
    
    
    class func showAlertWithCallBack(aMessageText: String ,  CompletionHandler : @escaping () -> ()){
        let alert: NSAlert = NSAlert()
        alert.messageText = aMessageText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            CompletionHandler()
        } 
    }
    
    
    class func showURLAlert(aMessageText: String?) -> String? {
        let alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "cancel_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        
        let windowFrame = NSApplication.shared.windows[0].frame
        let x = windowFrame.origin.x
        let newX = x + windowFrame.width
        let input = NSTextField(frame: NSMakeRect(0, 0, 500, 24))
       // let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        //input.placeholderString = aMessageText ?? ""
        input.placeholderString = " Kindly enter the URL to the KeyTalk configuration file as was provided to you"
        alert.accessoryView = input
        alert.window.level = .floating
        let button: NSApplication.ModalResponse = alert.runModal()
        if button.rawValue == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
            input.validateEditing()
            return input.stringValue
        } else if button.rawValue == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue  {
            return nil
        } else {
            let invalidInputDialogString = "invalid_input_dialog_button".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            assert(false, "\(invalidInputDialogString) \(button)")
            return nil
        }
    }
   
    ///////// Custom rccd Alert ////////
    class func showRCCDAlert(aMessageText: String?) -> String? {
        let alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "cancel_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.placeholderString = aMessageText ?? ""
        alert.accessoryView = input
        let button: NSApplication.ModalResponse = alert.runModal()
        if button.rawValue == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
            input.validateEditing()
            return input.stringValue
        } else if button.rawValue == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue  {
            return nil
        } else {
            let invalidInputDialogString = "invalid_input_dialog_button".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            assert(false, "\(invalidInputDialogString) \(button)")
            return nil
        }
    }
   
    
    //////////////////////////////////////////
    
    
    
    
    ////////// Customize UserName alert //////////
    class func showURLAlertForUserName(aMessageText: String?) -> String? {
        var alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "cancel_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.placeholderString = aMessageText ?? ""
        alert.accessoryView = input
        let button: NSApplication.ModalResponse = alert.runModal()
        let otpCount = 6
        let userNameCahracterCount = 0
        let responseCancel = 1001
        if button.rawValue == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
          
            while(input.stringValue.count == userNameCahracterCount && button.rawValue == 1000) {
                //input.validateEditing()
                //showPopupAlertOTP(aMessageText: "Enter Username")
                
                self.showPopupAlertOTP(aMessageText: "Username cannot be blank")
                if alert.runModal().rawValue == responseCancel {
                    return nil
                }
                
                //alert.runModal()
            }
            
            return input.stringValue
            
        } else if button.rawValue == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue  {
            return nil
        } else {
            let invalidInputDialogString = "invalid_input_dialog_button".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            assert(false, "\(invalidInputDialogString) \(button)")
            return nil
        }
    }
    
    
    
    ////////// Customize EMail empty alert //////////
    class func showEMailEmptyAlert(aMessageText: String?)
    {
        let alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        alert.informativeText = aMessageText!
            alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
            //alert.addButton(withTitle:"".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
            alert.alertStyle = NSAlert.Style.warning
            
        if alert.runModal().rawValue == 1000 {
            
            NSApplication.shared.windows[0].close()
        }
        
        //NSApplication.shared.windows[0].close()
        //alert.runModal()
        
       // return aMessageText!
        
    }
    
    
    //////// Customize EMail empty alert ////////
    ////
    class func showEMailAlertForOTP(aMessageText: String?) -> String? {
        var alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "cancel_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.placeholderString = aMessageText ?? ""
        alert.accessoryView = input
        let button: NSApplication.ModalResponse = alert.runModal()
        let otpCount = 6
        let responseCancel = 1001
        if button.rawValue == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
          
            while(!input.stringValue.contains("@") && button.rawValue == 1000) {
                input.validateEditing()
                showPopupAlertOTP(aMessageText: "Enter EMail ID")
                if alert.runModal().rawValue == responseCancel {
                    return nil
                }
                //alert.runModal()
            }
            
            return input.stringValue
            
        } else if button.rawValue == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue  {
            return nil
        } else {
            let invalidInputDialogString = "invalid_input_dialog_button".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            assert(false, "\(invalidInputDialogString) \(button)")
            return nil
        }
    }
    
   
    //////// Customize EMail alert for OTP /////////
    
    
    
    
    ///// Cutomize Alert for OTP /////////////
    class func showURLAlertForOTP(aMessageText: String?) -> String? {
        var alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "cancel_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.placeholderString = aMessageText ?? ""
        alert.accessoryView = input
        alert.window.level = .floating
        
        
    
        //NSApplication.shared.mainWindow?.frame.x
        
        //alert.accessoryView?.frame.minX = NSApplication.shared.mainWindow?.screen.        //let windowScreen = NSApplication.shared.mainWindow?.screen?.visibleFrame
        //let newOrigin = windowScreen?.origin

       // alert.accessoryView?.visibleRect.contains((NSApplication.shared.mainWindow?.screen?.frame.origin)!)
        //var leftOffset = NSApplication.shared.mainWindow?.screen?.visibleFrame

      
        
        
        
        let button: NSApplication.ModalResponse = alert.runModal()
        
        let otpCount = 6
        let responseCancel = 1001
        if button.rawValue == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
          
            while(input.stringValue.count != otpCount && button.rawValue == 1000) {
                input.validateEditing()
                showPopupAlertOTP(aMessageText: "One Time Password should be 6 characters long")
                if alert.runModal().rawValue == responseCancel {
                    return nil
            }
                //alert.runModal()
            }
            
            return input.stringValue
            
        } else if button.rawValue == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue  {
            return nil
        } else {
            let invalidInputDialogString = "invalid_input_dialog_button".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            assert(false, "\(invalidInputDialogString) \(button)")
            return nil
        }
        
        
    }
    
    
    /////// Customize Alert for OTP /////////
    
    
    ///// Cutomize Alert for OTP /////////////
    class func showURLAlertForOTPCopy(aMessageText: String?) -> String? {
        var alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "cancel_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.placeholderString = aMessageText ?? ""
        alert.accessoryView = input
        alert.window.level = .floating
        let button: NSApplication.ModalResponse = alert.runModal()
        let otpCount = 6
        let responseCancel = 1001
        if button.rawValue == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
          
            while(input.stringValue.count != otpCount && button.rawValue == 1000) {
                input.validateEditing()
                showPopupAlertOTP(aMessageText: "One Time Password should be 6 characters long")
                if alert.runModal().rawValue == responseCancel {
                    return nil
            }
                //alert.runModal()
            }
            
            return input.stringValue
            
        } else if button.rawValue == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue  {
            return nil
        } else {
            let invalidInputDialogString = "invalid_input_dialog_button".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            assert(false, "\(invalidInputDialogString) \(button)")
            return nil
        }
    }
    
    
    /////// Customize Alert for OTP /////////
    
    
    
    
    
    ///////Cutomize Alert for Password////
    
    class func showURLAlertForPassword(aMessageText: String?) -> String? {
        var alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "cancel_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.placeholderString = aMessageText ?? ""
        alert.accessoryView = input
        let button: NSApplication.ModalResponse = alert.runModal()
        
        let responseCancel = 1001
        let passwordEmptyValue = 0
        if button.rawValue == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
          
            
            
            while(input.stringValue.count == passwordEmptyValue && button.rawValue == 1000) {
                //input.validateEditing()
                showPopupAlertOTP(aMessageText: "Password cannot be blank")
                if alert.runModal().rawValue == responseCancel {
                    return nil
                }
            }
           
            return input.stringValue
            
        } else if button.rawValue == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue  {
            return nil
            
        } else {
            let invalidInputDialogString = "invalid_input_dialog_button".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            assert(false, "\(invalidInputDialogString) \(button)")
            return nil
        }
    }
    
    
    
    ///// Customize Alert for Password /////
    
    
    /**
     This NSAlert is presented to the user when the challnege is recieved in the communication.
     - Parameter aMessageText: This is the challenge message, or the type of challenge user recieves.
     - Returns: The user response corresponding to the challenge message.
     */
    class func showChallengeAlert(aMessageText: String?) -> String? {
        let alert: NSAlert = NSAlert()
        alert.messageText = "KeyTalk agent"
        alert.informativeText = aMessageText!
        alert.addButton(withTitle: "OK".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "Cancel".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        let input = NSSecureTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.placeholderString = "enter_your_response_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        alert.accessoryView = input
        let button: NSApplication.ModalResponse = alert.runModal()
        if button.rawValue == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
            input.validateEditing()
            return input.stringValue
        } else if button.rawValue == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue  {
            return nil
        } else {
            let invalidInputDialogString = "invalid_input_dialog_button".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            assert(false, "\(invalidInputDialogString) \(button)")
            return nil
        }
    }
    
    class func returnValidServerUrl(urlStr: String) -> String {
        var tempStr = urlStr
        if (!tempStr.contains("https")) {
            tempStr = "https://" + tempStr
        }
        if(tempStr.contains(":4443"))
        {
            tempStr = tempStr.replacingOccurrences(of:":4443", with: "")
        }
        return tempStr
    }
    
    class func resetGlobalMemberVariablesAccordingToUseCase(isUserInitiated:Bool) {
        if isUserInitiated {
            initialUsername = ""
            password = ""
            keytalkCookie = ""
            serviceName = ""
            dataCert = Data()
            serverUrl = ""
            gDownloadedCertificateModel = nil
        } else {
            bgDataCert = Data()
            gBGDownloadedCertificateModel = nil
        }
      
    }
    
    class func getVersionNumber() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return version
    }
    
    class func getBuildNumber() -> String {
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        return build
    }
    
    class func sha256(securityString : String) -> String {
        let data = securityString.data(using: .utf8)! as NSData
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in hash {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
    
    class func unZipFile(aPath: String) {
        do {
        let lChosenFilePath = aPath
        let lFileName = URL(fileURLWithPath: lChosenFilePath).lastPathComponent
            let rccd1 = DBHandler.getRCCDData()
            var rccdName = [String]()
            for i in 0..<rccd1!.count{
                rccdName.append(rccd1![i].name)
            }
        let lNewfileName = checkIfRCCDNameIsSame(str: lFileName, arr: rccdName)

        let lDestinationFile = sHomeDirectory + "/ImportedRCCDs"//sHomeDirectory.appendingPathComponent("UnzippedRCCDs", isDirectory: true)
        
            var lDestinationFilePath = lDestinationFile + "/\(lNewfileName)"//lDestinationFile.appendingPathComponent("\(lFileName)")
        if(lChosenFilePath != nil) {
            SSZipArchive.unzipFile(atPath: lChosenFilePath, toDestination: lDestinationFilePath)
           
            self.parse(aPath: lDestinationFilePath, aFileName: lNewfileName)
            
            }
        }catch {
            
        }
    }
   class func checkIfRCCDNameIsSame (str: String , arr: [String]) -> String {
    var newstr = str
    var newarr = arr.sorted()
    var ind = 2
    for i in 0..<arr.count {
        if newarr[i] == newstr
        {
            newstr = str + " \(ind)"
            newarr.append(newstr)
            ind += 1
            if newarr[i+1] != newstr {
                break
            }
        }
    }
    return newstr
    }
    
    class func parse(aPath: String, aFileName: String){
        do {
            let permission = LoginDBHandler.getHasPermissionBeenTaken()
            if permission == false {
                Utilities.showPopupAlert(aMessageText: "login_permission_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
                LoginDBHandler.saveHasPermissionBeenGivenToDatabase(hasPermissionBeenGiven: true)
            }
            var iniString : String?
            var imgData : Data?
            let lFileManager = FileManager.default
            if lFileManager.fileExists(atPath: aPath) {
                let lEnumerator:FileManager.DirectoryEnumerator = lFileManager.enumerator(atPath: aPath)!
                while let element1: String = lEnumerator.nextObject() as? String {
                    if element1.hasSuffix("png") {
                        let imagePath = aPath + "/\(element1)"
                        let images = try Data.init(contentsOf: URL(fileURLWithPath: imagePath))
                        if images != nil {
                            imgData = images
                        } else {
                            return
                        }
                    }
  //                      else if element1.hasSuffix("ini") {
//                        var element2 = URL(fileURLWithPath: element1).lastPathComponent
//                        let filePath = aPath + "/\(element1)"
//                        if lFileManager.fileExists(atPath: filePath){
//                            let content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
//                            let parsedINIString = Parser.parseIni(aIniString: content)
//                            iniString = parsedINIString
//                        }
                        else if element1.contains("user.ini") {
                            var element2 = URL(fileURLWithPath: element1).lastPathComponent
                            let filePath = aPath + "/\(element1)"
                            if lFileManager.fileExists(atPath: filePath){
                                let content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
                                let parsedINIString = Parser.parseIni(aIniString: content)
                                iniString = parsedINIString
                            }
                        else {
                            let _ = Utilities.showAlert(aMessageText: "invalid_rccd_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
                        }
                    } else if element1.hasSuffix("yaml"){
                        let element2 = URL(fileURLWithPath: element1).lastPathComponent
                        let filePath = aPath + "/\(element1)"
                        let content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
                        let parsedYAMLString = Parser.parseYaml(aYamlString: content)
                        print(parsedYAMLString)
                    }
                    /** This block of code is used to install the CA certificates to Keychain present in RCCD file. With reference to the mail with subject: KeyTalk release 5.5.6 for globally trusted certificate support, Mike asked to install the CA certificates from the APIs similar to keyTalk iOS  **/

                    else if element1.hasSuffix("der"){
                        let filePath = aPath + "/\(element1)"
                        let lCertLoader = CertificateLoader()
                        lCertLoader.loadDERCertificate(path: filePath)
                    }
 
                }
                DBHandler.saveToDatabase(rccd: aFileName, withConfig: iniString!, aImageData: imgData!)
                if let importedRCCDFile = DBHandler.getRCCD(rccdName: aFileName) {
                    var ProviderArr = [String]()
                    var ServicesArr = [String]()
                    let providerList = importedRCCDFile.users[0].Providers
                    for provider in providerList {
                        ProviderArr.append(provider.Name)
                        let servicesList = provider.Services
                        for service in servicesList {
                            ServicesArr.append(service.Name)
                            Utilities.init().logger.write("RCCD with Name:\(aFileName), Providers: \(provider.Name), Services: \(service.Name) imported successfully")
                        }
                    }
                } else {
                    }
                }
            
            else {
                let _ = Utilities.showAlert(aMessageText: "check_internet_connection_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
            }
        }catch {
            print(error.localizedDescription)
        }
    }
    
    
    /**
     This method is used to get the time difference between a timestamp and the current date of the system.
     If the timestamp is in close to the current timestamp of the system , then the system will be notified with a bool value.
     
     - Parameter timeStamp: The timestamp in the string format to find the difference with the current date.
     - Returns: A bool value , notifies that the timestamp is close to the current date.
     */
    class func checkTimeStampValidity(with timeStamp: String) -> Bool {
        //2017-04-06T04:15:15+0000
        var isValid = false
        
        //initializing the date format with the Current System Timezone and the date format in string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone.current
        
        //converting the server timestamp into Date .
        let timeStampDate = dateFormatter.date(from: timeStamp)
        
        //setting thr calendar components to calculate the difference between the dates.
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        
        //getting the actual difference between the dates in terms of days,hours, minutes and seconds
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: timeStampDate!, to: Date())
        
        if difference.day! == 0  && difference.hour! == 0 && difference.minute! < 5 {
            //returns true , only if the difference between the dates is less than 5 MINUTES .
            isValid = true
        }
        
        //return true if the difference is less than 5 minutes, else returns false.
        return isValid
    }
    
    /**
     This method is used to download the CRL file using the CRL URL from certificate.
     
     - Parameter url: The url to download CRL from.
     - Parameter aSerialNumber: The serial number of the certificate from where CRL URL has been retrieved.
     */
    class func downloadCRLFile(url: String, aSerialNumber: String){
        do {
            let lURL = URL(string: url)!
            let lSerialNumber = aSerialNumber
            //store crl file using this filename
            let lFileName = lURL.lastPathComponent
            //destination path to download the RCCD file
            let lDestinationFilePath = sHomeDirectory + "/DownloadedCRLs"
            let lFileManager = FileManager.default
            try lFileManager.createDirectory(atPath: lDestinationFilePath, withIntermediateDirectories: true, attributes: nil)
            let lFilePath = lDestinationFilePath + "/\(lFileName)"
            
            //download the crl file
            let lSessionConfiguration = URLSessionConfiguration.default
            let lSession = URLSession(configuration: lSessionConfiguration)
            let lRequest = try! URLRequest(url: lURL)
            let lTask = lSession.downloadTask(with: lRequest) { (tempLocalUrl, response, error) in
                if let lTempLocalUrl = tempLocalUrl, error == nil {
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Success: \(statusCode)")
                        //crl file downloaded successfully
                        do {
                            //check if file already exists
                            if lFileManager.fileExists(atPath: lFilePath){
                                //remove item from path
                                try lFileManager.removeItem(atPath: lFilePath)
                            }
                            //copy downloaded file to the path
                            try lFileManager.copyItem(atPath: lTempLocalUrl.path, toPath: lFilePath)
                            
                        }catch{
                        }
                         //convert contents of CRL file to text
                        convertCRLtoText(aPath: lFilePath, aSerialNumber: lSerialNumber)
                    }
                } else {
                    print("Failure: %@", error?.localizedDescription as Any)
                    Utilities.init().logger.write((error?.localizedDescription)!)
                }
            }
            lTask.resume()
        }catch {
            Utilities.init().logger.write("\(error.localizedDescription)")
        }
    }
    
    /**
     This method is used to convert the contents of CRL file to text.
     
     - Parameter aPath: The path of the downloaded file.
     - Parameter aSerialNumber: The serial number of the certificate used to check if certificate has been revoked or not.
     */
    class func convertCRLtoText(aPath: String, aSerialNumber: String) {
        let path = aPath
        let crlTextString = runCommand(cmd: "/usr/bin/env", args: "openssl", "crl", "-inform", "DER", "-noout", "-text", "-in", "\(path)")// "ssca-sha2-g5.crl")
        if crlTextString.output[0] == ""{
            NotificationManager.sharedManager().showNotification(informativeText: "crl_could_not_converted_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        }
        for i in 0..<crlTextString.output.count {
            if (crlTextString.output[i].contains(aSerialNumber))
            {
                print("certificate found")
               let certInfo = DBHandler.getDataforSerialNumber(serialNumber: aSerialNumber)
                let certData = certInfo?.data
                let commonname = certInfo?.commonName
                let certForString = "certificate_for_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
                if certInfo?.isSMIME == false {
                
                    NotificationManager.sharedManager().showActionNotification(informativeText: "\(String(describing: certInfo?.commonName)) \(certForString) \(String(describing: certInfo?.associatedServiceName)) \("service_revoked_deleted_string".localizedNotify(UserDefaults.standard.value(forKeyPath: "LanguageChangeSelected") as! String))", identifier: (certInfo?.associatedServiceName)!)
                } else {
                    let service_revoked_not_deleted_string = "service_revoked_not_deleted_string".localizedNotify(UserDefaults.standard.value(forKeyPath: "LanguageChangeSelected") as! String)
                    NotificationManager.sharedManager().showNotification(informativeText: "\(String(describing: certInfo?.commonName)) \(certForString) \(String(describing: certInfo?.associatedServiceName)) \(service_revoked_not_deleted_string)")
                }
                
            }
            
        }
    }
   
    /**
     This method is used to convert the contents of CRL file to text.
     
     - Parameter cmd: The command to convert CRL file to text.
     - Parameter args: The arguements passed with the command to convert CRL file to text.
     - Returns: A String array , containing the converted CRL file.
     - Returns: A String array , containing the descriptive error occured while converting CRL to text.
     - Returns: An Int value , containing the exit code.
     */
    class func runCommand(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
    
    /**
     This method is used to get the current Time.
     */
   class func getTimeStamp()-> NSDate {
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
        return time
    }
    
    class func editConfigPlist(searchBase: [String], serverURL: [String]) {
        // Mike Requested for a temporary disabling the LDAP configuaration //////
//        let pathForPlist = copyConfigPlist()
//        var LDAPDictionary = NSMutableDictionary(contentsOfFile: pathForPlist)
//        var LDAPArray = LDAPDictionary!["PayloadContent"]! as! NSMutableArray
//        var searchBase1 = ""
//        var serverURL1 = ""
//        for i in 0..<searchBase.count {
//            searchBase1 = searchBase[i]
//            serverURL1 = serverURL[i]
//            serverURL1 = serverURL1.replacingOccurrences(of: "ldap://", with: "")
//            serverURL1 = serverURL1.replacingOccurrences(of: "ldaps://", with: "")
//            var index = serverURL1.range(of: ":")?.lowerBound
//            serverURL1 = String(serverURL1.prefix(upTo: index!) )
//
//            let data = Utilities.createLDAPDictionary(plistPath: pathForPlist, searchBase: searchBase1, serverURL: serverURL1)
//            LDAPArray.add(data)
//        }
//        // Mike Requested for a temporary disabling the LDAP configuaration //////
        
        
        
        
//        for i in 0..<LDAPArray.count {
//        let LDAPArrayFromPlist = LDAPArray[i] as! NSMutableDictionary
//        LDAPArrayFromPlist["LDAPAccountHostName"] = serverURL1
//        let LDAPArrayFromPlistNew = LDAPArrayFromPlist["LDAPSearchSettings"] as! NSMutableArray
//        let LDAPDictionaryFromPlist = LDAPArrayFromPlistNew[0] as! NSMutableDictionary
//        
//        LDAPDictionaryFromPlist["LDAPSearchSettingSearchBase"]! = searchBase1
 
        
        
        
        
        // Mike Requested for a temporary disabling the LDAP configuaration //////
        //LDAPDictionary?.write(toFile: pathForPlist, atomically: true)
        // Mike Requested for a temporary disabling the LDAP configuaration //////
        
        //        }
    //    let plistURL = URL(fileURLWithPath: pathForPlist)  // URL.init(string: plistPath)
       // try plistData.write(to: plistURL)
        
        // Mike Requested for a temporary disabling the LDAP configuaration //////
        //changePlistToMobileConfig(path: pathForPlist)
        // Mike Requested for a temporary disabling the LDAP configuaration //////
    }
    
//    class func createLDAPDictionary(plistPath: String, searchBase: String, serverURL: String)-> NSDictionary {
//        //var plistData: NSData? = nil
//        var dictionary: NSDictionary?
//        do {
//            let uuidString = UUID().uuidString
//            
//            let dict = ["LDAPSearchSettingDescription": "My Search", "LDAPSearchSettingScope": "LDAPSearchSettingScopeSubtree","LDAPSearchSettingSearchBase": searchBase ]
//            let array = [dict]
//            dictionary = ["LDAPAccountDescription": "KeyTalk client LDAP", "LDAPAccountHostName" : serverURL ,"LDAPAccountUseSSL": true,"LDAPSearchSettings":array, "PayloadDescription": "Configures an LDAP account", "PayloadDisplayName": "LDAP", "PayloadIdentifier": "com.apple.ldap.account.F45C832E-81E9-46D0-8E54-0BA7F5C553D0", "PayloadType": "com.apple.ldap.account", "PayloadUUID": uuidString, "PayloadVersion": "1"] as [String : Any] as NSDictionary
//            //plistData = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0) as NSData
//            
//        } catch {
//            print(error)
//        }
//        return dictionary!
//
//    }
  
    // Mike Requested for a temporary disabling the LDAP configuaration //////
//    class func editConfigPlist(searchBase: String, serverURL: String) {
//        let pathForPlist = copyConfigPlist()
//        let searchBase = searchBase
//        let serverURL = serverURL
//
//        var LDAPDictionary = NSMutableDictionary(contentsOfFile: pathForPlist)
//        var LDAPArray = LDAPDictionary!["PayloadContent"]! as! NSMutableArray
//        let LDAPArrayFromPlist = LDAPArray[0] as! NSMutableDictionary
//        LDAPArrayFromPlist["LDAPAccountHostName"] = serverURL
//       let LDAPArrayFromPlistNew = LDAPArrayFromPlist["LDAPSearchSettings"] as! NSMutableArray
//        let LDAPDictionaryFromPlist = LDAPArrayFromPlistNew[0] as! NSMutableDictionary
//
//        LDAPDictionaryFromPlist["LDAPSearchSettingSearchBase"]! = searchBase
//        LDAPDictionary?.write(toFile: pathForPlist, atomically: true)
//        changePlistToMobileConfig(path: pathForPlist)
//    }
    // Mike Requested for a temporary disabling the LDAP configuaration //////
    
  
    
    // Mike Requested for a temporary disabling the LDAP configuaration //////
//    class func changePlistToMobileConfig(path: String) {
//        do {
//        let plistPath = path
//            var folderPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/KeyTalk client/KeyTalkLDAPMobileConfig"
//            do {
//                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
//                let timestamp = Utilities.getTimeStamp()
//                folderPath = folderPath + "/KeyTalkLDAP" + "\(timestamp)" + ".mobileconfig"
//                if FileManager.default.fileExists(atPath: folderPath) {
//
//                }else {
//                    try FileManager.default.copyItem(atPath: plistPath, toPath: folderPath)
//                }
//
//                 showLDAPGuide()
//                    saveConfigurations(path: folderPath)
//
//            } catch {
//
//            }
//        }
//        // Mike Requested for a temporary disabling the LDAP configuaration //////
        
  //  }
    
    class func saveConfigurations(path: String) {
        
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.open(url)
    }
    
    
   
    // Mike Requested for a temporary disabling the LDAP configuaration //////
//    class func copyConfigPlist()->String {
//        let pathForConfigPlist = Bundle.main.path(forResource: "KeyTalkTestDemo", ofType: "plist")
//        var pathForPlist = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/KeyTalk client/KeyTalkLDAPPlist"
//        do {
//            let timeStamp = getTimeStamp()
//            try FileManager.default.createDirectory(atPath: pathForPlist, withIntermediateDirectories: true, attributes: nil)
//            pathForPlist = pathForPlist + "/KeyTalkLDAP" + "\(timeStamp)" + ".plist"
//            if FileManager.default.fileExists(atPath: pathForPlist) {
//
//            }else {
//                try FileManager.default.copyItem(atPath: pathForConfigPlist!, toPath: pathForPlist)
//            }
//        } catch {
//
//        }
//        return pathForPlist
//    }
    // Mike Requested for a temporary disabling the LDAP configuaration //////
    
     
    // Mike Requested for a temporary disabling the LDAP configuaration //////
//    class func showLDAPGuide() {
//        let storyboard = NSStoryboard.init(name: "Main", bundle: nil)
//        let identifier = NSStoryboard.SceneIdentifier("LDAPGuideViewController")
//        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? NSViewController else {
//            fatalError("Why cant i find LDAPGuideViewController? - Check Main.storyboard")
//        }
//        let sViewController = ViewController()
//        sViewController.presentAsModalWindow(viewcontroller)
//    }
    // Mike Requested for a temporary disabling the LDAP configuaration //////
    
//    class func downloadPEMCert(lURL: String) {
//        do {
//
//            //store crl file using this filename
//            let lURL1 = URL.init(fileURLWithPath: lURL)
//            let lFileName = lURL1.lastPathComponent
//            //destination path to download the RCCD file
//            let lDestinationFilePath = sHomeDirectory + "/DownloadedPEMs"
//            let lFileManager = FileManager.default
//            try lFileManager.createDirectory(atPath: lDestinationFilePath, withIntermediateDirectories: true, attributes: nil)
//            let lFilePath = lDestinationFilePath + "/\(lFileName)"
//
//            //download the crl file
//            let lSessionConfiguration = URLSessionConfiguration.default
//            let lSession = URLSession(configuration: lSessionConfiguration)
//            let lRequest = try! URLRequest(url: lURL1)
//            let lTask = lSession.downloadTask(with: lRequest) { (tempLocalUrl, response, error) in
//                if let lTempLocalUrl = tempLocalUrl, error == nil {
//                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                        print("Success: \(statusCode)")
//                        //crl file downloaded successfully
//                        do {
//                            //check if file already exists
//                            if lFileManager.fileExists(atPath: lFilePath){
//                                //remove item from path
//                                try lFileManager.removeItem(atPath: lFilePath)
//                            }
//                            //copy downloaded file to the path
//                            try lFileManager.copyItem(atPath: lTempLocalUrl.path, toPath: lFilePath)
//
//                        }catch{
//                        }
//                        //convert contents of CRL file to text
//                        convertPEMtoDER(aPath: lFilePath)
//                    }
//                } else {
//                    print("Failure: %@", error?.localizedDescription as Any)
//                    Utilities.init().logger.write((error?.localizedDescription)!)
//                }
//            }
//            lTask.resume()
//        }catch {
//            Utilities.init().logger.write("\(error.localizedDescription)")
//        }
//    }
//    class func convertPEMtoDER(aPath: String) {
//
//    }
    
}
