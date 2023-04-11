//
//  ServicesViewController.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Cocoa
import AppKit
import SSZipArchive
import Foundation
import Gzip
import Zip

class ServicesViewController: NSViewController, NSTextFieldDelegate {
    
    //MARK:- Variables
    let mHomeDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/KeyTalk client"//FileManager.default.homeDirectoryForCurrentUser
    
    // Models
    let vcmodel = VCModel()
    
    //Selected Service Variable
    //sets whent the rccd file is selected in the TableView.
    var selectedRCCD : rccd? {
        
        
        didSet {
            self.handleMenuModel(selectedRCCD)
        }
    }
    
    //sets the selected service value from the drop down menu
    var selectedService : String? {
        didSet {
            self.handleServiceSelection(service: selectedService)
        }
    }
    // Timer instances, to handle the delay encountered.
    var timer = Timer()
    var isTimerRunning = false
    var delayTimeInSeconds : Int = 0
    
    // Selected Service
    var currentSelectedService :String = String()
    var lastSelectedService :String = String()
    
    //Challenge Variable, to encounter the challenges faces by the user.
    var challengeMessage = String()
    var serverResponseCookie :String? = nil
    
    //LDAP Arrays
    var serverURLArray = [String]()
    var searchBaseArray = [String]()
    
    //loader view
    var mLoaderView : NSView?
    
    
    //MARK:- IBOutlet
    @IBOutlet weak var showRCCDServices: NSPopUpButton!
    
    
    
    
    @IBOutlet weak var lImageView: NSImageView!
    @IBOutlet weak var lVersionTextField: NSTextField!
    
    @IBOutlet weak var lBox: NSBox!
    
    @IBOutlet weak var lLoginButtonOutlet: NSButton!
    @IBOutlet weak var lLoginButton: NSButtonCell!
    
    
    //weak var delegate: OTPDelegate?
    
    @IBOutlet weak var lOTPTextField: NSTextField!
    
    @IBOutlet weak var userNameTexLabel: NSTextField!
    @IBOutlet weak var lUserNameTextField: NSTextField!
    
    @IBOutlet weak var passwordLabel: NSTextField!
    @IBOutlet weak var lPasswordTextField: NSSecureTextField!
    
    @IBOutlet weak var emailLAbel: NSTextField!
    @IBOutlet weak var lEmailTextField: NSTextField!
    
    @IBOutlet weak var otpTextLabel: NSTextField!
    @IBOutlet weak var otpTextField: NSTextField!
    
    @IBOutlet var servicesLabel: NSTextField!
    
    @IBOutlet weak var fullUserNameLabel: NSTextField!
    @IBOutlet weak var fullUserNameTextField: NSTextField!
    
    
    
    //MARK:- Lifecycle Methods.
    /**
     Method is an override method, called after the view controller’s view has been loaded into memory.
     */
    override func viewDidLoad() {
        //sets the loader view
        var currentLocaleLang = Locale.current.languageCode
        let valueInUserDefaults = UserDefaults.standard.value(forKey: "LanguageChangeSelected")
        if valueInUserDefaults == nil {
            if let valueExistsInEnum = LanguageEnum(rawValue: currentLocaleLang!) {//LanguageEnum.init(rawValue: currentLocaleLang!)  {
                UserDefaults.standard.set(valueExistsInEnum, forKey: "LanguageChangeSelected")
            } else {
                UserDefaults.standard.set("en", forKey: "LanguageChangeSelected")
            }
        }else {
            UserDefaults.standard.set(valueInUserDefaults, forKey: "LanguageChangeSelected")
        }
        let setLang = UserDefaults.standard.value(forKey: "LanguageChangeSelected")
        LanguagePrefrenceDBHandler.saveLanguagePreferencetoDatabase(languageSelected: setLang as! String)
        
        lUserNameTextField.isHidden = false
        
        emailLAbel.stringValue = "Kindly provide your email address".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        
        otpTextLabel.stringValue = "Please enter the One Time Password as sent to your provided email address".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        servicesLabel.stringValue = "Services".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        setUpLoaderView()
        
        //modify login button
        lLoginButtonOutlet.layer?.cornerRadius = 0
        lLoginButtonOutlet.bezelStyle = .texturedSquare
        
        //sets the app version number on the UI.
        fullUserNameLabel.stringValue = "common_name".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        lVersionTextField.stringValue = "\("version".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)) \(Bundle.main.releaseVersionNumber!)"
        
    }
    
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    /**
     Method is an override method, called when the view controller’s view is fully transitioned onto the screen.
     */
    override func viewDidAppear() {
        //sets up the model class
        setUpModel()
        //sets the default image icon.
        lImageView.image = #imageLiteral(resourceName: "logo")
        
        lLoginButtonOutlet.title = "Next".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        
        emailLAbel.isHidden = true //Email label
        lEmailTextField.isHidden = true
        
        otpTextLabel.isHidden = true
        otpTextField.isHidden = true
        
        userNameTexLabel.isHidden = true  // Username
        lUserNameTextField.isHidden = true
        
        passwordLabel.isHidden = true        //Password
        lPasswordTextField.isHidden = true
        
        fullUserNameLabel.isHidden = true     //Full Username (Common Name)
        fullUserNameTextField.isHidden = true
        
        if(fullUserNameTextField.stringValue != "")
        {
            fullUserNameTextField.stringValue = ""
        }
        
        /* Flushing the Email input field */
        self.lEmailTextField.stringValue = ""
        /* Flushing the Email input field */
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedPassword(notification:)), name: Notification.Name("PASSWORD NOTIFICATION"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedOTP(notification:)), name: Notification.Name("OTP-NOTIFICATION"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedOTPINPUT(notification:)), name: Notification.Name("OTP-INPUT_REQUIRED-NOTIFICATION"), object: nil)
        
    }
    func askToDownloadOtherCerts()-> Bool{
        let alert: NSAlert = NSAlert()
        alert.messageText = "download_historical_certs".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        
        alert.alertStyle = .warning
        alert.addButton(withTitle: "yes".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        alert.addButton(withTitle: "no".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            //          print("anaaaa")
            return true
        }else{
            return false
        }
        //        if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
        //          print("bacchan")
        //        }
    }
    
    func triggerInitialOperations()
    {
        lLoginButtonOutlet.title = "Next".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        
        let servicess = showRCCDServices.titleOfSelectedItem
        
        guard let services = showRCCDServices.titleOfSelectedItem , servicess!.count > 0 else {
            let _ = Utilities.showAlert(aMessageText: "select_service_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
            
            return
        }
        //gets the model associated with the RCCD file selected by the user.
        let model = selectedRCCD?.users[0].Providers[0]
        
        //sets the seleted model into the global variable for database handling.
        gDownloadedCertificateModel = DownloadedCertificate(rccdName: selectedRCCD?.name, user: [(selectedRCCD?.users[0])!] , cert: nil)
        
        
        if let _ = showRCCDServices.titleOfSelectedItem {
            
            // valid url for API hit
            let serviceURL = Utilities.returnValidServerUrl(urlStr: (model?.Server)!)
            serverUrl = serviceURL
            
            //name of the selected service
            serviceName = showRCCDServices.titleOfSelectedItem!
            
            vcmodel.apiService = ConnectionHandler(servicename: serviceName, /*username: username, password: password,*/ server: serviceURL, challengeResponse: nil)
            
            //common name condition
            if(emailTextFieldValue != "" && serviceName != "") {
                emailAsignForCommonName = emailTextFieldValue
                let newSuccess = vcmodel.requestForApiService(urlType: .commonNameCase)
                emailAsignForCommonName = ""
            }
            
            //commom name condition
            
            //request for API request with hello URL
            let success = vcmodel.requestForApiService(urlType: .hello)
        }
        
        Utilities.init().logger.write("hit the server for hello request")
        
    }
    
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    @objc func methodOfReceivedOTP(notification: Notification) {
        // Take Action on Notification
        
        DispatchQueue.main.async { [self] in
            
            self.otpTextField.stringValue = ""
            
            self.userNameTexLabel.isHidden = true
            self.lUserNameTextField.isHidden = true
            
            self.passwordLabel.isHidden = true
            self.lPasswordTextField.isHidden = true
            
            self.emailLAbel.isHidden = false
            self.lEmailTextField.isHidden = false
            
        }
    }
    
    
    @objc func methodOfReceivedOTPINPUT(notification: Notification)
    {
        
        lLoginButtonOutlet.title = "login".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        // lLoginButtonOutlet.title = "Next"
        
        self.otpTextLabel.isHidden = false
        self.otpTextField.isHidden = false
        commonName = ""
        
        
        if(ALLOWED == true){
            fullUserNameLabel.isHidden = false
            fullUserNameTextField.isHidden = false
            
        }
        
        otpTextFieldValue = (self.otpTextField.stringValue as? String)!
        OTPText = otpTextFieldValue
        
    }
    
    
    @objc func methodOfReceivedPassword(notification: Notification) {
        // Take Action on Notification
        
        DispatchQueue.main.async { [self] in
            
            lLoginButtonOutlet.title = "login".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            
            self.lUserNameTextField.stringValue = ""
            self.lPasswordTextField.stringValue = ""
            
            self.emailLAbel.isHidden = true
            self.lEmailTextField.isHidden = true
            
            self.otpTextLabel.isHidden = true
            self.otpTextField.isHidden = true
            
            self.userNameTexLabel.isHidden = false
            self.lUserNameTextField.isHidden = false
            
            self.passwordLabel.isHidden = false
            self.lPasswordTextField.isHidden = false
            
            
            
            Password = ""
            print("Please Enter the username")
            print("Please Enter the Password")
            
            print("\(password) \n")
            print(Password)
            
            //initialUsername = (self.lUserNameTextField.stringValue as? String)!
            //password = (self.lPasswordTextField.stringValue as? String)!
            
            //            if initialUsername.count > 0 {print("username has a value")}
            //            if(password.count > 0) {print("password has a value")
            //                self.lPasswordTextField.stringValue = ""
            //            }
            
        } //main queue
    }
    
    
    
    /**
     This method is used to set the loader on the View.
     */
    func setUpLoaderView() {
        
        //sets the loader view with the frame of the base view.
        mLoaderView = NSView.init(frame: self.view.frame)
        
        //creating a central view containing the progreea indicator and a text field.,
        let loaderView = NSView.init(frame: .init(x: self.view.frame.width/2-100, y: self.view.frame.height/2-100, width: 200 , height: 200))
        loaderView.alphaValue = 1
        //sets the layer of the view.
        loaderView.wantsLayer = true
        loaderView.layer?.borderColor = NSColor.black.cgColor
        loaderView.layer?.backgroundColor = NSColor.init(red: 255, green: 255, blue: 255, alpha: 0.0).cgColor
        
        //initiates the progress indicator on the view.
        let acticityIndicator = NSProgressIndicator.init(frame: .init(x: 80, y: 80, width: 40, height: 40))
        //sets the style to the progess indicator and background view
        acticityIndicator.style = .spinning
        acticityIndicator.controlTint = NSControlTint.graphiteControlTint
        acticityIndicator.wantsLayer = true
        acticityIndicator.layer?.backgroundColor = NSColor.clear.cgColor
        acticityIndicator.startAnimation(self)
        loaderView.addSubview(acticityIndicator)
        
        let pleaseWaitTxtFld = NSTextField.init(frame: NSRect.init(x: 30, y: 50, width: 140, height: 30))
        pleaseWaitTxtFld.alignment = .center
        pleaseWaitTxtFld.textColor =  .black
        pleaseWaitTxtFld.backgroundColor = .clear
        pleaseWaitTxtFld.isBezeled = false
        pleaseWaitTxtFld.isEditable = false
        //
        pleaseWaitTxtFld.font = NSFont.init(descriptor: .init(), size: 15)
        loaderView.addSubview(pleaseWaitTxtFld)
        
        //adding the central view on the main loader view.
        mLoaderView?.addSubview(loaderView)
    }
    
    //MARK:- NSTextFielsDelegateMethod
    /**
     Method is an NSTextField delegate method, returns the controll to the private method on clicking enter.
     */
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        loginButtonTapped(self)
        return true
    }
    
    //MARK:- IBAction
    /**
     ActionButton is used to show the services of the selected RCCD.
     */
    @IBAction func showRCCDServicesActionButton(_ sender: NSPopUpButton){
        self.selectedService = sender.titleOfSelectedItem
    }
    
    /**
     ActionButton is used to login using the credentials entered.
     */
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        
        
        //        let storyboard = NSStoryboard.init(name: "Main", bundle: nil)
        //        let identifier = NSStoryboard.SceneIdentifier("LDAPGuideViewController")
        //        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? LDAPGuideViewController else {
        //            fatalError("Why cant i find LDAPGuideViewController? - Check Main.storyboard")
        //        }
        //        let sViewController = ViewController()
        //        sViewController.presentAsModalWindow(viewcontroller)
        
        //Utilities.showLDAPGuide()
        //validates the username , password and service name , before sending the server request.
        
        
        //        if(sender as! NSObject == self as NSObject)
        /* Flushing the email value getting cached from previous run*/
        emailTextFieldValue = ""
        /* Flushing the email value getting cached from previous run*/
        
        //Username and Password Values input
        initialUsername = (self.lUserNameTextField.stringValue as? String)!
        
        if(lPasswordTextField.stringValue.count > 0) {
            password = (self.lPasswordTextField.stringValue as? String)!
        }
        
        else {
            password = ""
            lPasswordTextField.stringValue = ""
        }
        
        //email
        emailTextFieldValue  = (self.lEmailTextField.stringValue as? String)!
        /* If EMail does not hava a value it should just return */
        
        
        //otpTextFieldValue = self.otpTextField.stringValue as String
        
        guard let servicess = showRCCDServices.titleOfSelectedItem , servicess.count > 0 else {
            let _ = Utilities.showAlert(aMessageText: "select_service_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
            return
        }
        
        //gets the model associated with the RCCD file selected by the user.
        let model = selectedRCCD?.users[0].Providers[0]
        
        //sets the seleted model into the global variable for database handling.
        gDownloadedCertificateModel = DownloadedCertificate(rccdName: selectedRCCD?.name, user: [(selectedRCCD?.users[0])!] , cert: nil)
        
        
        //////Services
        if let _ = showRCCDServices.titleOfSelectedItem {
            
            // valid url for API hit
            let serviceURL = Utilities.returnValidServerUrl(urlStr: (model?.Server)!)
            serverUrl = serviceURL
            
            //name of the selected service
            serviceName = showRCCDServices.titleOfSelectedItem!
            
            vcmodel.apiService = ConnectionHandler(servicename: serviceName, /*username: username, password: password,*/ server: serviceURL, challengeResponse: nil)
            /////////////////////////////////////////////////////////////////////////
            
            ////////////////////////// common name condition ////////
            if(emailTextFieldValue != "" && serviceName != "") {
                emailAsignForCommonName = emailTextFieldValue
                let newSuccess = vcmodel.requestForApiService(urlType: .commonNameCase)
                emailAsignForCommonName = ""
            }
            
            /////////////////////// commo name condition ///////////
            
            if(ALLOWED == true){
                if commonName != ""
                {commonName = "" }
                commonName = fullUserNameTextField.stringValue as String
                
            }
            
            //////// OTP setting and initilailizing the authentication
            if(otpForRequest == true && password == "")
            {
                otpTextFieldValue = self.otpTextField.stringValue as String
                OTPText = otpTextFieldValue
                
                let success = vcmodel.requestForApiService(urlType: .authentication)
                otpForRequest = false
                otpTextFieldValue = ""
                return
            }
            
            //request for API request with hello URL
            let success = vcmodel.requestForApiService(urlType: .hello)
        }
        
        
        Utilities.init().logger.write("hit the server for hello request")
    }
    
    
    
    
    //MARK:- PrivateMethods
    
    /**
     This method is used to download the certificate after the authentication is completed.
     */
    private func downloadCertificate(aCookie:String) {
        do {
            Utilities.init().logger.write("server hit for certificate download initiated")
            
            //json model of the selected service,gets the server url associated with the selected rccd file.
            let model = selectedRCCD?.users[0].Providers[0].Server
            let serviceName = selectedRCCD?.users[0].Providers[0].Services[0].Name
        
            //json-serialization of the model
            let dict = try JSONSerialization.jsonObject(with: dataCert, options: []) as? [String:Any]
            let r = randomString(length: 3)
            //gets the status of the response.
            if let status = dict!["status"] as? String {
                
                //if auth status is cert.
                if status == "cert" {
                    
                   
                    guard let certUrlStr = dict!["cert-url-templ"] as? String,certUrlStr.count > 0 else{
                        DispatchQueue.main.async {
                            self.resetAll(aServicesArray: false, username: nil)
                            let _ = Utilities.showAlert(aMessageText: "error_communication_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
                        }
                        return
                    }
                    // 29 March
                    
                    let historicalURL = dict!["historical-certs-url-templ"] as? String
                    if(historicalURL?.count ?? 0>0){
                        if(askToDownloadOtherCerts()){
                            print("ASP3401  Download Historical Cetficates")
                            
                        
                       
                            guard let historicalCertsUrlStr = dict!["historical-certs-url-templ"] as? String,historicalCertsUrlStr.count > 0 else{
                                DispatchQueue.main.async {
                                    self.resetAll(aServicesArray: false, username: nil)
                                    print("Some ERROR")
                                    let _ = Utilities.showAlert(aMessageText: "error_communication_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
                                }
                                return
                            }
                            print("Historical cert url \(historicalCertsUrlStr)")
                          
                            donwloadZIP(aCookie, dict!, model! , historicalCertsUrlStr, serviceName!)
                           
                           donwloadCerts(aCookie, dict!, model! , certUrlStr, r)
                        //hellooooooo
                           
                        }else{
                            print("Do not Download Historical Certificates")
                            donwloadCerts(aCookie, dict!, model! , certUrlStr, r)
                        }
                    }
                    else{
                        print("ASP says dont download")
                        donwloadCerts(aCookie, dict!, model! , certUrlStr, r)
                    }
                    
               
                    
                    //                    var s=dict!["cert-url-templ"]
                    //                    var p=dict!["status"]
                    //                    Utilities.showAlertForLastMessage(aMessageText: "succDescription")
                    //                    print("JMM")
                    //  print(dict!["status"])
                    //   var item1 = dict!["cert-url-templ"] as? [String:Any]
                    
                    //    var item2  = dict!["status"] as? [String:Any]
                    
                    //                    var array_name = [Any]()
                    //                    array_name.append(s)
                    //                    array_name.append(p)
                    //                    for name in array_name {
                    //                        print("ASP")
                    //                          print(name)
                    //                    }
                    //                    for index in 1...2 {
                    
                    //                        guard let certUrlStr = dict!["cert-url-templ"] as? String,certUrlStr.count > 0 else{
                    //                            DispatchQueue.main.async {
                    //                                self.resetAll(aServicesArray: false, username: nil)
                    //                                let _ = Utilities.showAlert(aMessageText: "error_communication_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
                    //                            }
                    //                            return
                    //                        }
                    //
                    //                        //password of the p12 certificate, retrieves it from the cookie recieved from hello hit.
                    //                        //spliting the cookie to get the certificate password.
                    //                        let passcode = aCookie.components(separatedBy: "=")[1]
                    //                        let index = passcode.index((passcode.startIndex), offsetBy: 30)
                    //                        let subString = passcode[..<index]
                    //
                    //                        //sets the server url for the certificate downloading.
                    //                        let serverString = model
                    //
                    //                        if certUrlStr.count > 0 {
                    //
                    //                            //creating a valid url withe service host url and the certificate url.
                    //                            let tempURLString = certUrlStr.replacingOccurrences(of: "$(KEYTALK_SVR_HOST)", with: serverString!)
                    //                            print(" ASP3401 Temp url \(tempURLString)")
                    //                            //
                    //                            let serviceURLString = Utilities.returnValidServerUrl(urlStr: (tempURLString))
                    //                            let certURL = URL(string: serviceURLString)
                    //
                    //                            print("Service URL String is = \(serviceURLString)")
                    //                            print("Certificate String is = \(certURL)")
                    //                            //
                    //
                    //                           // let certURL = URL(string: tempURLString)
                    //
                    //                            //filename of the certificate
                    //                            let fileName = (certURL?.lastPathComponent)! + ".p12"
                    //
                    //                            //destination path to store the downloaded certificate
                    //                            let destinationPath = mHomeDirectory + "/DownloadedCertificates"//mHomeDirectory.appendingPathComponent("DownloadedCertificates", isDirectory: true)
                    //
                    //                            //create directory for downloaded certificates
                    //                            try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
                    //                            let filePath = destinationPath + "/\(fileName)"//destinationPath.appendingPathComponent(fileName, isDirectory: false)
                    //
                    //                            //download the certificate
                    //                            let sessionConfig = URLSessionConfiguration.default
                    //                            let session = URLSession(configuration: sessionConfig)
                    //                            let request = try! URLRequest(url: certURL!)
                    //                            let task = session.downloadTask(with: request) {
                    //
                    //                                (tempLocalUrl, response, error) in
                    //                                if let tempLocalUrl = tempLocalUrl, error == nil {
                    //                                    Utilities.init().logger.write("certificate downloaded successfully")
                    //
                    //                                    //Certificate downloaded successfully
                    //                                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    //                                        print("Success: \(statusCode)")
                    //                                        do {
                    //                                            //check if file already exists
                    //                                            if FileManager.default.fileExists(atPath: filePath){
                    //                                                //remove item from path
                    //                                                try FileManager.default.removeItem(atPath: filePath)
                    //                                            }
                    //                                            //copy downloaded file to the path
                    //                                            try FileManager.default.copyItem(atPath: tempLocalUrl.path, toPath: filePath)
                    //
                    //                                            //resets all the varibles
                    //                                            self.resetAll(aServicesArray: true, username: initialUsername)
                    //
                    //                                            //saves the downloaded certificate into the database and keychain.
                    //                                            let lCertificateLoader = CertificateLoader()
                    //                                            let certiModel = DownloadedCertificate(rccdName: self.selectedRCCD?.name, user: (self.selectedRCCD?.users)!, cert: nil)
                    //
                    //                                            Utilities.init().logger.write("downloaded certificate is sent to be loaded in the keychain and also to be saved in the database")
                    //                                            UserDetailsHandler.saveUsernameAndServices(rccdname: (self.selectedRCCD?.name)!, username: initialUsername, services: serviceName)
                    //                                            //get downloaded certificates from database
                    //                                            let downloadedCerts = DownloadedCertificateHandler.getTrustedCertificateData()
                    //                                            if (downloadedCerts?.count)! > 0 {
                    //                                                for downloadedCertificates in downloadedCerts! {
                    //                                                    let serviceName = downloadedCertificates.downloadedCert?.cert?.associatedServiceName
                    //                                                    let usenameforService = downloadedCertificates.downloadedCert?.cert?.username
                    //                                                   // let textFieldUsername = self.lUserNameTextField.stringValue
                    //                                                    let textFieldUsername = userName
                    //                                                    DispatchQueue.main.async {
                    //                                                        let service = self.showRCCDServices.titleOfSelectedItem
                    //
                    //
                    //                                                    if ( textFieldUsername == usenameforService && service == serviceName){
                    //                                                        //check if the currently downloaded certificate is SMIME
                    //                                                        if downloadedCertificates.downloadedCert?.cert?.isSMIME == false {
                    //                                                            //if not SMIME, delete the previous expired certificate from keychain
                    //                                                            let fingerPrint = downloadedCertificates.downloadedCert?.cert?.fingerPrint
                    //                                                            CertificateHandler.deleteCertificates(fingerprint: (fingerPrint)!)
                    //                                                        }    } else {
                    //                                                            //if SMIME, certificate is not deleted from Keychain
                    //                                                            print("SMIME Certificate found: installing new one")
                    //                                                        }
                    //                                                        self.setUpModel()
                    //                                                    }
                    //                                                }
                    //                                            }
                    //                                             //load p12 certificate and store it in Keychain
                    //                                            lCertificateLoader.loadPKCSCertificate(path: filePath, p12Password: String(subString), isUserInitiated: true, certificateModel: certiModel, aServiceUsername: userName, aServiceName: serviceName, completion: { (success) in
                    //                                                if success {
                    //                                                    self.vcmodel.requestForApiService(urlType: .lastMessage)
                    //                                                } else {
                    //                                                    Utilities.init().logger.write("could not load certificate.")
                    //                                                }
                    //                                            })
                    //
                    //                                        } catch {
                    //                                            Utilities.init().logger.write("could not download certificate.")
                    //                                        }
                    //                                    }
                    //                                } else {
                    //                                    Utilities.init().logger.write("could not download certificate due to:  \(String(describing: error?.localizedDescription))")
                    //                                }
                    //                            }
                    //                            task.resume()
                    //
                    //                        }
                    //
                    //                    else {
                    //                        DispatchQueue.main.async {
                    //                            self.resetAll(aServicesArray: false, username: nil)
                    //                            Utilities.init().logger.write("could not initiate certificate downloading, resetting every parameter")
                    //                        }
                    //                    }
                }
                //                    }
                
                //gets the url from which the certificate needs to be downloaded.
            }
        }
        catch {
            Utilities.init().logger.write("could not initiate certificate downloading, certificate download failed  \(String(describing: error.localizedDescription))")
        }
        
    }
    private func donwloadCerts(_ aCookie : String, _ dict : [String : Any] , _ model : String , _ certUrlStr : String, _ randomValue : String){
        do{
            
//            guard let certUrlStr = dict["cert-url-templ"] as? String,certUrlStr.count > 0 else{
//                DispatchQueue.main.async {
//                    self.resetAll(aServicesArray: false, username: nil)
//                    let _ = Utilities.showAlert(aMessageText: "error_communication_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
//                }
//                return
//            }
            
            //password of the p12 certificate, retrieves it from the cookie recieved from hello hit.
            //spliting the cookie to get the certificate password.
            print("Password \(aCookie)")
            let passcode = aCookie.components(separatedBy: "=")[1]
            let index = passcode.index((passcode.startIndex), offsetBy: 30)
            let subString = passcode[..<index]
            print("Password \(subString)")
            //sets the server url for the certificate downloading.
            let serverString = model
            
            if certUrlStr.count > 0 {
                
                //creating a valid url withe service host url and the certificate url.
                let tempURLString = certUrlStr.replacingOccurrences(of: "$(KEYTALK_SVR_HOST)", with: serverString)
                print(" ASP3401 Temp url \(tempURLString)")
                //
                let serviceURLString = Utilities.returnValidServerUrl(urlStr: (tempURLString))
                let certURL = URL(string: serviceURLString)
                
                print("Service URL String is = \(serviceURLString)")
                print("Certificate String is = \(certURL)")
                //
                
                // let certURL = URL(string: tempURLString)
                
                //filename of the certificate
                let fileName = (certURL?.lastPathComponent)! + randomValue + ".p12"
                
                //destination path to store the downloaded certificate
                let destinationPath = mHomeDirectory + "/DownloadedCertificates"//mHomeDirectory.appendingPathComponent("DownloadedCertificates", isDirectory: true)
                
                //create directory for downloaded certificates
                try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
                let filePath = destinationPath + "/\(fileName)"//destinationPath.appendingPathComponent(fileName, isDirectory: false)
                print("ASP3401 File Path::" + filePath )
                //download the certificate
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                let request = try! URLRequest(url: certURL!)
                let task = session.downloadTask(with: request) {
                    
                    (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        Utilities.init().logger.write("certificate downloaded successfully")
                        
                        //Certificate downloaded successfully
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Success: \(statusCode)")
                            do {
                                //check if file already exists
                                if FileManager.default.fileExists(atPath: filePath){
                                    //remove item from path
                                    try FileManager.default.removeItem(atPath: filePath)
                                }
                                //copy downloaded file to the path
                                try FileManager.default.copyItem(atPath: tempLocalUrl.path, toPath: filePath)
                                
                                //resets all the varibles
                                self.resetAll(aServicesArray: true, username: initialUsername)
                                
                                //saves the downloaded certificate into the database and keychain.
                                let lCertificateLoader = CertificateLoader()
                                let certiModel = DownloadedCertificate(rccdName: self.selectedRCCD?.name, user: (self.selectedRCCD?.users)!, cert: nil)
                                
                                Utilities.init().logger.write("downloaded certificate is sent to be loaded in the keychain and also to be saved in the database")
                                UserDetailsHandler.saveUsernameAndServices(rccdname: (self.selectedRCCD?.name)!, username: initialUsername, services: serviceName)
                                //get downloaded certificates from database
                                let downloadedCerts = DownloadedCertificateHandler.getTrustedCertificateData()
                                if (downloadedCerts?.count)! > 0 {
                                    for downloadedCertificates in downloadedCerts! {
                                        let serviceName = downloadedCertificates.downloadedCert?.cert?.associatedServiceName
                                        let usenameforService = downloadedCertificates.downloadedCert?.cert?.username
                                        // let textFieldUsername = self.lUserNameTextField.stringValue
                                        let textFieldUsername = userName
                                        DispatchQueue.main.async {
                                            let service = self.showRCCDServices.titleOfSelectedItem
                                            
                                            
                                            if ( textFieldUsername == usenameforService && service == serviceName){
                                                //check if the currently downloaded certificate is SMIME
                                                if downloadedCertificates.downloadedCert?.cert?.isSMIME == false {
                                                    //if not SMIME, delete the previous expired certificate from keychain
                                                    let fingerPrint = downloadedCertificates.downloadedCert?.cert?.fingerPrint
                                                    CertificateHandler.deleteCertificates(fingerprint: (fingerPrint)!)
                                                }    } else {
                                                    //if SMIME, certificate is not deleted from Keychain
                                                    print("SMIME Certificate found: installing new one")
                                                }
                                            print("ASP3401 Downloaded" )
                                            self.setUpModel()
                                        }
                                    }
                                }
                    //            load p12 certificate and store it in Keychain
                                //31 March
                                lCertificateLoader.loadPKCSCertificate(path: filePath, p12Password: String(subString), isUserInitiated: true, certificateModel: certiModel, aServiceUsername: userName, aServiceName: serviceName, completion: { (success) in
                                    if success {
                                        Utilities.showAlertForCertificateAlreadtExistsMessage(aMessageText: "Authentication was successful, certificate and key were successfully installed")
                                        self.vcmodel.requestForApiService(urlType: .lastMessage)
                                    } else {
                                        Utilities.init().logger.write("could not load certificate.")
                                    }
                                })
                                print("files Hello")
                                //uncomment this
//                                let lastfilename = self.selectedRCCD?.users[0].Providers[0].Services[0].Name
//                                if( self.unzipTgzFileAtPath("historical-certs",lastfilename!)){
//                                    print("Abhishek I am here 2");
//                                    do {
////                                        let destination = self.mHomeDirectory + "/DownloadedCertificates/historical_certs/"
//                                        let destination = self.mHomeDirectory + "/DownloadedCertificates/historical-certs/\(lastfilename!)/"
//                                        let files = try FileManager.default.contentsOfDirectory(atPath: destination)
//
//                                        for file in files {
//                                            if(file.contains(".p12")){
////                                            if(file.contains(".p12")){
//                                                print(" Abhishek:: \(destination)\(file)")
//                                                let mpath=destination+file;
//                                              //  lCertificateLoader.loadDERCertificate(path: mpath)
//                                                print("John sharma Path::: \(mpath)")
//                                                print("John sharma p12Password:::\(String(subString))")
//                                                print("John sharma userName:::\(userName)")
//                                           //    let mPassword="c337fcc4feef4297af5ad74d9d1850"
//                                                lCertificateLoader.loadPKCSCertificate(path: mpath, p12Password: String(subString), isUserInitiated: true, certificateModel: certiModel, aServiceUsername: userName, aServiceName: serviceName, completion: { (success) in
//
//                                                    if success {
//                                                        print(mpath)
//                                                        print("John sharma Success")
//                                                      //  self.vcmodel.requestForApiService(urlType: .lastMessage)
//                                                    } else {
//                                                        print("John sharma Not  Success")
//                                                        //Utilities.init().logger.write("could not load certificate.")
//                                                    }
//                                                })
//
//                                            }
//
//                                        }
//
//
//                                    } catch {
//                                        print("Abhishek I am here 4");
//                                        print(error)
//                                    }
//                                } else{
//                                    print("Abhishek I am here 3");
//                                    Utilities.init().logger.write("could not unzipp multiple certs:  \(String(describing: error?.localizedDescription))")
//                                }
                                
                            } catch {
                                print("ASP3401 Exception");
                                Utilities.init().logger.write("could not download certificate.")
                            }
                        }
                     //   self.myUnZip()
                       
//                        if( self.unzipTgzFileAtPath((certURL?.lastPathComponent)!,model)){
//                            do {
//                                let destination = self.mHomeDirectory + "/DownloadedCertificates/historical-certs/"
//                                let files = try FileManager.default.contentsOfDirectory(atPath: destination)
//                                for file in files {
//                                    if(file.contains(".p12")){
//                                        print(" Abhishek:: \(destination)\(file)")
//                                    }
//
//                                }
//
//
//                            } catch {
//                                print(error)
//                            }
//                        } else{
//                            Utilities.init().logger.write("could not unzipp multiple certs:  \(String(describing: error?.localizedDescription))")
//                        }
                       
                    } else {
                        Utilities.init().logger.write("could not download certificate due to:  \(String(describing: error?.localizedDescription))")
                    }
                }
                task.resume()
                
            }
            
            else {
                DispatchQueue.main.async {
                    self.resetAll(aServicesArray: false, username: nil)
                    Utilities.init().logger.write("could not initiate certificate downloading, resetting every parameter")
                }
            }
        } catch{
            
        }
    
    }
    private func donwloadZIP(_ aCookie : String, _ dict : [String : Any] , _ model : String , _ certUrlStr : String, _ randomValue : String){
     
        do{
            print("ASP3401 Downloading ZIP")
//            guard let certUrlStr = dict["cert-url-templ"] as? String,certUrlStr.count > 0 else{
//                DispatchQueue.main.async {
//                    self.resetAll(aServicesArray: false, username: nil)
//                    let _ = Utilities.showAlert(aMessageText: "error_communication_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String), tag: 1)
//                }
//                return
//            }
            
            //password of the p12 certificate, retrieves it from the cookie recieved from hello hit.
            //spliting the cookie to get the certificate password.
            print("Password \(aCookie)")
            let passcode = aCookie.components(separatedBy: "=")[1]
            let index = passcode.index((passcode.startIndex), offsetBy: 30)
            let subString = passcode[..<index]
            print("Password \(subString)")
            //sets the server url for the certificate downloading.
            let serverString = model
            
            if certUrlStr.count > 0 {
                
                //creating a valid url withe service host url and the certificate url.
                let tempURLString = certUrlStr.replacingOccurrences(of: "$(KEYTALK_SVR_HOST)", with: serverString)
                print(" ASP3401 Temp url \(tempURLString)")
                //
                let serviceURLString = Utilities.returnValidServerUrl(urlStr: (tempURLString))
                let certURL = URL(string: serviceURLString)
                
                print("Service URL String is = \(serviceURLString)")
                print("Historical Certificate String is = \(certURL)")
                //
                
                // let certURL = URL(string: tempURLString)
                
                //filename of the certificate
                let fileName = (certURL?.lastPathComponent)! + randomValue + ".tgz"
                
                //destination path to store the downloaded certificate
                let destinationPath = mHomeDirectory + "/DownloadedCertificates"//mHomeDirectory.appendingPathComponent("DownloadedCertificates", isDirectory: true)
                
                //create directory for downloaded certificates
                try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
                let filePath = destinationPath + "/\(fileName)"//destinationPath.appendingPathComponent(fileName, isDirectory: false)
                print("ASP3401 File Path::" + filePath )
                //download the certificate
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                let request = try! URLRequest(url: certURL!)
                let task = session.downloadTask(with: request) {
                    
                    (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        Utilities.init().logger.write("certificate downloaded successfully")
                        
                        //Certificate downloaded successfully
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Success: \(statusCode)")
                            do {
                                //check if file already exists
                                if FileManager.default.fileExists(atPath: filePath){
                                    //remove item from path
                                    try FileManager.default.removeItem(atPath: filePath)
                                }
                                //copy downloaded file to the path
                                try FileManager.default.copyItem(atPath: tempLocalUrl.path, toPath: filePath)
                              
                                //resets all the varibles
                              //  self.resetAll(aServicesArray: true, username: initialUsername)
                                
                                //saves the downloaded certificate into the database and keychain.
                              
                           // remove from here
                                let lastfilename = self.selectedRCCD?.users[0].Providers[0].Services[0].Name
                                if( self.unzipTgzFileAtPath("historical-certs",lastfilename!)){
                                   
                                    do {
//                                        let destination = self.mHomeDirectory + "/DownloadedCertificates/historical_certs/"
                                        let destination = self.mHomeDirectory + "/DownloadedCertificates/historical-certs/\(lastfilename!)/"
                                        let files = try FileManager.default.contentsOfDirectory(atPath: destination)
                                       
                                            for file in files {
                                                if(file.contains(".p12")){
                                                    //                                            if(file.contains(".p12")){
                                                    print(" Abhishek:: \(destination)\(file)")
                                                    let mpath=destination+file;
                                                    //  lCertificateLoader.loadDERCertificate(path: mpath)
                                                    print("ASP3401 Path::: \(mpath)")
                                                    print("ASP3401 p12Password:::\(String(subString))")
                                                    print("ASP3401 userName:::\(userName)")
                                                    //    let mPassword="c337fcc4feef4297af5ad74d9d1850"
                                                    let lCertificateLoader = CertificateLoader()
                                                    let certiModel = DownloadedCertificate(rccdName: self.selectedRCCD?.name, user: (self.selectedRCCD?.users)!, cert: nil)
                                                    lCertificateLoader.loadPKCSCertificate(path: mpath, p12Password: String(subString), isUserInitiated: true, certificateModel: certiModel, aServiceUsername: userName, aServiceName: serviceName, completion: { (success) in
                                                        
                                                        if success {
                                                            print(mpath)
                                                            Utilities.init().logger.write("Historical certificate loaded here")
                                                            
                                                            print("ASP3401 Success")
                                                            //  self.vcmodel.requestForApiService(urlType: .lastMessage)
                                                          
                                                        } else {
                                                            print("ASP3401 Not  Success")
//                                                            Utilities.init().logger.write("could not load certificate. here")
                                                        }
                                                    })
                                                    
                                                }
                                                
                                            }
                                            
                                        
                                    } catch {
                                        print("ASP3401 Exception");
                                        print(error)
                                    }
                                } else{
                                    print("ASP3401 Could not unzipp");
                                    Utilities.init().logger.write("could not unzipp multiple certs:  \(String(describing: error?.localizedDescription))")
                                }

                            
                            } catch {
                                Utilities.init().logger.write("could not download certificate.")
                            }
                        }
                     //   self.myUnZip()
                        

                       
                    } else {
                        Utilities.init().logger.write("could not download certificate due to:  \(String(describing: error?.localizedDescription))")
                    }
                }
                task.resume()
                
            }
            
            else {
                DispatchQueue.main.async {
                    self.resetAll(aServicesArray: false, username: nil)
                    Utilities.init().logger.write("could not initiate certificate downloading, resetting every parameter")
                }
            }
        } catch{
            
        }
    
    }
    
    private func askToInstallOtherCertsAswell(){
        let alert: NSAlert = NSAlert()
        alert.messageText = "Abhishek Sharma"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "ok_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
           // CompletionHandler()
            
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
    func unzipTgzFile(_ randomValue : String) {
        let task = Process()
        task.launchPath = "/usr/bin/tar"
        let destinationPath = mHomeDirectory + "/DownloadedCertificates/\(randomValue)"
        task.arguments = ["-xzf", destinationPath]
        print("Abhishek3401");
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        print(output)
        print("Abhishek3401");
    }
    func unzip(){
      print("Abhishek34012");
        let filePath = mHomeDirectory + "/DownloadedCertificates/abhishek.tgz"
        let fileURL = URL(fileURLWithPath: filePath)
        
        let compressedZipFilePath = mHomeDirectory + "/DownloadedCertificates/abhishek.zip"
        let compressedZipFileURL = URL(fileURLWithPath: compressedZipFilePath ,isDirectory: true)
        
        
       // let filePath = "/path/to/file.txt"
      
       
//        SSZipArchive.unzipFile(atPath: destinationPath ,  toDestination: toPath)
       print("Abhishek34012");
//        print(fileURL);
        do{
           let compressedData = try Data(contentsOf: fileURL)
            print("1");
            let uncompressedData = try compressedData.gunzipped()
            print("2");
          try uncompressedData.write(to: compressedZipFileURL, options: .atomic)
            print("3");
            
            let lastfilePath = mHomeDirectory + "/DownloadedCertificates/abhishek.tgz"
            let lastfilePath2 = mHomeDirectory + "/DownloadedCertificates/abhishek"
            SSZipArchive.unzipFile(atPath: lastfilePath,  toDestination: lastfilePath2)
            print("4");
        }catch{
            print("5");
        }
       
        }
        
    func myUnZip(){
        let filePath = mHomeDirectory + "/DownloadedCertificates"
        let destination = mHomeDirectory + "/DownloadedCertificates/abhishek"
        do {
            let filePath = Bundle.main.url(forResource: "abhishek", withExtension: ".tgz")!
            let unzipDirectory = try Zip.quickUnzipFile(filePath) // Unzip
         //   let zipFilePath = try Zip.quickZipFiles([filePath], fileName: "archive") // Zip
        }
        catch {
          print("Something went wrong")
        }
        
       
      

            
        
   
    
    }
    func unzipTgzFileAtPath(_ lastcomponent : String ,_ randomValue : String) -> Bool {
        print("unzipTgzFileAtPath is called");
        let filePath = mHomeDirectory + "/DownloadedCertificates/\(lastcomponent)\(randomValue).tgz"
        print("filePath:::\(filePath)");
        print("lastcomponent:::\(lastcomponent)");
        print("randomValue:::\(randomValue)");
        let destination = mHomeDirectory + "/DownloadedCertificates/historical-certs/\(randomValue)/"
      
       
        let fileManager = FileManager.default
        do
        {
            try fileManager.createDirectory(atPath: destination, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Error while creating a folder.")
        }
        
        
      //  let destination = mHomeDirectory + "/DownloadedCertificates/abc"
        let task = Process()
        task.launchPath = "/usr/bin/tar"
        task.arguments = ["-xzvf", filePath, "-C", destination]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        task.waitUntilExit()
        
        return task.terminationStatus == 0
    }
    /**
     This method is used to handle the api request to the server according to the URL.
     The URL type is used to notify that the server communication is successful for that URL and to call the next sequential server request.
     
     - Parameter typeUrl: Type of URL for server communication.
     */
    private func handleAPIs(typeUrl: URLs) {
        switch typeUrl {
        case .hello:
            vcmodel.requestForApiService(urlType: .handshake)
        case .handshake:
            vcmodel.requestForApiService(urlType: .authReq)
        case .authReq:
            vcmodel.requestForApiService(urlType: .authentication)
        case .authentication:
            vcmodel.requestForApiService(urlType: .addressBook)
        case .addressBook:
            vcmodel.requestForApiService(urlType: .certificate)
        case .challenge:
            vcmodel.requestForApiService(urlType: .certificate)
        case .certificate:
            //cookie is been used to fetch the password for the certificate to be downloaded.
            self.downloadCertificate(aCookie: self.serverResponseCookie!)
        case .lastMessage:
            print("last message recieved.")
            //vcmodel.requestForApiService(urlType: .lastMessage)
         //   self.askToDownloadOtherCerts();
        
        case .commonNameCase:
            print("comm name Qualification")
            //vcmodel.requestForApiService(urlType: .commonName)
        case .determineTheKindOFCredentials:
            print("a test case")
        }
    }
    
    /**
     This method is used to handle the last message retrieved from the server.
     This message is retrieved when communication is successful i.e. certificate is successfully returned from the server.
     
     - Parameter messageArr: Dictionary of last messages.
     */
    private func handleRetrievedLastMesage (messageArr : [Dictionary<String,String>]?) {
        
        if let lastMessageArr = messageArr {
            if !lastMessageArr.isEmpty {
                for messages in lastMessageArr {
                    let text = messages["text"]
                    let utc = messages["utc"]
                    if let _text = text {
                        if let _utcTimeStamp = utc {
                            if Utilities.checkTimeStampValidity(with: _utcTimeStamp) {
                                Utilities.showAlertWithCallBack(aMessageText: _text) {
                                    return
                                }
                            }
                        }
                    }
                }
            } else {
                //got empty message as the last message from the server.
            }
        }
        redirectingToHOTURL()
    }
    
    
    // Mike Requested for a temporary disabling the LDAP configuaration //////
//
//    private func handleAddressBook (messageArr : [Dictionary<String,String>]?) {
//
//        if let AddressBook = messageArr {
//            if !AddressBook.isEmpty {
//
//                for addresses in AddressBook {
//                    let serverURL = addresses["ldap_svr_url"]
//                    let searchBase = addresses["search_base"]
//                    if let _serverURL = serverURL {
//                        if let _searchBase = searchBase {
//                            if AddressBook.count >= 1 {
//                                serverURLArray.append(_serverURL)
//                                searchBaseArray.append(_searchBase)
//                            } else {
//                            }
//                        }
//                    }
//                }
//
//                /// Mike Requested for a temporary disabling the LDAP configuaration //////
//                //Utilities.editConfigPlist(searchBase: searchBaseArray, serverURL: serverURLArray)
//                /// Mike Requested for a temporary disabling the LDAP configuaration //////
//            } else {
//                //got empty message as the last message from the server.
//            }
//        }
//        //redirectingToHOTURL()
//    }
    
    // Mike Requested for a temporary disabling the LDAP configuaration //////
    
    /**
     This method is used to handle Menu model of the selected RCCD file.
     The UserModel contains all the information of the selected RCCD file, parse it to show corresponding services.
     
     - Parameter UserModel: Stores information of the selected RCCD file.
     */
    private func handleMenuModel(_ rccdModel:rccd?) {
        
        ALLOWED = false
        
        emailLAbel.isHidden = true //Email label
        lEmailTextField.isHidden = true
        
        otpTextLabel.isHidden = true
        otpTextField.isHidden = true
        
        userNameTexLabel.isHidden = true  // Username
        lUserNameTextField.isHidden = true
        
        passwordLabel.isHidden = true        //Password
        lPasswordTextField.isHidden = true
        
        fullUserNameLabel.isHidden = true     //Full Usernam//e (Common Name)
        fullUserNameTextField.isHidden = true
        
        lPasswordTextField.stringValue = ""
        password = ""
        Password = ""
    
        
        let userModel = rccdModel?.users[0]
        resetAll(aServicesArray: true, username: nil)
        var serviceArr = [String]()
        
        guard let _ = userModel else {
            showRCCDServices.removeAllItems()
            return
        }
        
        //parse UserModel to retrieve services in it
        if let provider = userModel?.Providers[0] {
            for i in 0..<provider.Services.count  {
                let services = provider.Services[i].Name
                serviceArr.append(services)
            }
            //parse UserModel to get RCCD logo
            guard let imageLogo = userModel?.Providers[0].imageLogo
                else {
                    showRCCDServices.removeAllItems()
                    lImageView.image = #imageLiteral(resourceName: "logo")
                    showRCCDServices.addItems(withTitles: serviceArr)
                    return
            }
            
            showRCCDServices.removeAllItems()
            if let imageData = NSImage(data: imageLogo) {
                //show image logo to the corresponding selected RCCD on the UI
                lImageView.image = imageData
            } else {
                lImageView.image = #imageLiteral(resourceName: "logo")
            }
            
            //shuffles the service array
            serviceArr = swapLastSelectedService(serviceArr)
            
            
            
            
            //gets the username for the associated service from the database.
            if let lastEnteredUsername = UserDetailsHandler.getUsername(from: (rccdModel?.name)!, for: serviceArr[0]) {
                DispatchQueue.main.async {
                    //if username is stored in the database, sets it in the username textfield.
                    self.lUserNameTextField.stringValue = lastEnteredUsername
                }
            }

        ///// flow to accomodate the user, email and password in grey area between service and login //
            //request for API request with hello URL
            //self.vcmodel.requestForApiService(urlType: .hello)
            
        ///// flow to accomodate the user, email and password in grey area between service and login //
        
            //show services to the corresponding selected RCCD on the UI
            showRCCDServices.addItems(withTitles: serviceArr)
            
            if toDetermineCredentials == false
               {
                self.triggerInitialOperations()
               }
            
        }
    }
    
    /**
     This function is used to handle the selected service of the drop down menu or the PopUpButton.
     In this method, the last saved username for the selected service is taken from the database and is value is populated in the Username textfield.
     - Parameter service: the service name for which the username is required.
     - Returns: the username associated with the service, if present in the database, otherise an empty value is returned.
     */
    private func handleServiceSelection(service : String?) {
        //variable to store the username value, if present , otherwise set to empty.
        var usernameSavedWithService = ""
        if let _service = service {
            //gets the username associated with the given service, if present in the database
            let lastSavedUsername = UserDetailsHandler.getUsername(from: (selectedRCCD?.name)!, for: _service)
            if let _username = lastSavedUsername {
                //if username exits, stores it in a variable
                usernameSavedWithService = _username
            }
            
            
        }
        DispatchQueue.main.async {
            self.lUserNameTextField.stringValue = usernameSavedWithService
          //  self.lPasswordTextField.stringValue = ""
        }
    }
    
    /**
     This method is used to shuffle the services array present in the selected rccd file.
     In this , the services array elements are shuffled and the first element of this array is replaced with the last service used by the user.
     - Parameter rccdServices: An array of services present in the selected rccd file, which needs to be shuffled.
     - Returns: An array , with the last used service at the initial index.
     */
    private func swapLastSelectedService(_ rccdServices: [String]?) -> [String] {
        //gets the last used service name in the given rccd file.
        let lastEntry = UserDetailsHandler.getLastSavedEntry()
        
        if var arrServices = rccdServices {
            //iterating through the service array.
            for i in 0..<arrServices.count {
                //if any element matches the last used service
                if arrServices[i] == lastEntry?.service {
                    //swapping the required element with the zero index element of the array.
                    let temp = arrServices[i]
                    arrServices[i] = arrServices[0]
                    arrServices[0] = temp
                    //returns the shuffled array.
                    return arrServices
                }
            }
        } else {
            return rccdServices!
        }
        return rccdServices!
    }
    
    /**
     This method is used to set up the VCModel instances for the callbacks, So that when the variables will set then the appropriate actions can be taken.
     */
    private func setUpModel() {
        //set up the alert message closure with an alert.
        vcmodel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.vcmodel.alertMessage {
                    //shows alert with the encountered message.
                   
                   
                    self!.lLoginButtonOutlet.title =  "Next".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)  //  "Next"
                     
                    self?.lEmailTextField.stringValue = ""
                    
                    //////////// before executung the authentication failed completion handler////
                    if self?.vcmodel.emailFlag == true
                    {
                    self?.emailLAbel.isHidden = false//true //Email label
//                        emailLAbel.stringValue = 
                    self!.lEmailTextField.isHidden = false
                    }
                    
                    self!.otpTextLabel.isHidden = true
                    self!.otpTextField.isHidden = true
                    
                    self!.userNameTexLabel.isHidden = true  // Username
                    self!.lUserNameTextField.isHidden = true
                    
                    self!.passwordLabel.isHidden = true        //Password
                    self!.lPasswordTextField.isHidden = true
                    
                    self!.fullUserNameLabel.isHidden = true     //Full Usernam//e (Common Name)
                    self!.fullUserNameTextField.isHidden = true
                    
                   
                    
                    ///////////////////////////////////////////////////////////////////////////////////////////////
                    
                    
                    
                    let _ = Utilities.showAlert(aMessageText: message, tag: 1)
                }
            }
        }
        
        //set up the delay closure, when the delay is encountered
        vcmodel.delayTimeClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let delayTime = self?.vcmodel.delayTime {
                    print("delayTime is :::::::\(delayTime)")
                    //starts the Timer with the encountered delay time.
                    self?.setTimerWithDelay(delay: delayTime)
                }
            }
        }
        //set up the challenge closure, when the challenge is encountered.
        vcmodel.showChallengeClosure = {[weak self] (challengeType,challengeValue) in
            DispatchQueue.main.async {
                //calls to handle the challenge.
                self?.handleChallenges(challengeType: challengeType, challengeValue: challengeValue)
            }
        }
        
        vcmodel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                if let loading = self?.vcmodel.isLoading {
                    if loading {
                        self?.startLoader()
                    }
                    else {
                        self?.stopLoader()
                    }
                }
            }
        }
        
        vcmodel.successFullResponse = { [weak self] (urlType) in
            DispatchQueue.main.async {
                self?.handleAPIs(typeUrl: urlType)
            }
        }
        
        vcmodel.setCookie = { [weak self] () in
            DispatchQueue.main.async {
                if let cookie = self?.vcmodel.serverCookie {
                    //sets the server cookie into the local variable to be used further into the app.
                    self?.handleCookie(response: cookie)
                }
            }
        }
        
        vcmodel.setCertifcateData = { [weak self] () in
            DispatchQueue.main.async {
                if let _dataCert = self?.vcmodel.certificateData {
                    //sets the server cookie into the local variable to be used further into the app.
                    dataCert = _dataCert
                }
            }
        }
        
        vcmodel.retrieveLastMessage = { [weak self] (lastmessage) in
            DispatchQueue.main.async {
                self?.handleRetrievedLastMesage(messageArr: lastmessage)
                print("************** test Scenario")
            }
        }
        
        
        // Mike Requested for a temporary disabling the LDAP configuaration //////
//        vcmodel.retrieveAddressBook = { [weak self] (addressBook) in
//            DispatchQueue.main.async {
//                self?.handleAddressBook(messageArr: addressBook)
//            }
//        }
        
        // Mike Requested for a temporary disabling the LDAP configuaration //////
        
    }
    
    /**
     This method is used to start the activity indicator on the UI to inform the user about the sysytem activity and also to restrict them to perform any other activity other than the one which is already executing
     */
    private func startLoader() {
        self.view.addSubview(mLoaderView!)
        self.lLoginButton.isEnabled = false
    }
    
    /**
     This method is used to remove or stop the activity indicatior after the system perform any activity.
     */
    private func stopLoader() {
        mLoaderView?.removeFromSuperview()
        self.lLoginButton.isEnabled = true
    }
    
    /**
     This method is used to retrieve the cookie , send by the server inrder to utilize it, further into the application.
     - Parameter cookie: The cookie value recieved from the server
     */
    private func handleCookie(response cookie:String?) {
        guard let _cookie = cookie , !_cookie.isEmpty else {
            return
        }
        
        //if cookie contains any value, then it will be stored into a local variable.
        serverResponseCookie = _cookie
        Utilities.init().logger.write("cookie retrived by the hello hit")
    }
    
    
    /**
     This method is used to handle the challenge when the user encounters it.
     
     - Parameter challengeType: Type of challenge encountered.
     - Parameter challengeValue: The Challenge message encountered.
     */
    private func handleChallenges(challengeType:ChallengeResult,challengeValue:String) {
        
        Utilities.init().logger.write("challenge encountered by the user")
        
        //sets the name of challenge in a variable
        challengeMessage = challengeValue
        challengeName = ChallengeResult.PassWordChallenge.rawValue
        
        //calls to display the challenge view to the user, to register their response.
        showChallengeView(challengeValue,false)
    }
    
    /**
     This method is used to display the challenge view with the encountered challenge message.
     
     - Parameter message: The challenge message encountered.
     - Parameter toHide: A bool value to indicate the visibility of the challenge View.
     */
    private func showChallengeView(_ message:String,_ toHide:Bool) {
        //makes the challenge view visible to the user.
        //self.view.viewWithTag(222)?.isHidden = toHide
        
        //sets the challenge message on the view.
        guard let response = Utilities.showChallengeAlert(aMessageText: message) else {
            let _ = Utilities.showPopupAlert(aMessageText: "response_empty_terminating_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String))
            return
        }
        challengePopUpOkClicked(response)
    }
    
    /**
     This method is used to redirect to hotURL.
     in this after successful communication i.e. when certificate has been received, redirection happens at hotURL .
     */
    private func redirectingToHOTURL () {
        guard let services = selectedRCCD?.users[0].Providers[0].Services else {
            return
        }
        let lastDownloadedCert = DownloadedCertificateHandler.getCertificateInformation(rccd: (selectedRCCD?.name)!, for: showRCCDServices.titleOfSelectedItem!)
        for service in services {
            if service.Name == showRCCDServices.titleOfSelectedItem! {
                if !service.Uri!.isEmpty {
                    //Disabling Check for SMIME hotURL
                    //}&& !(lastDownloadedCert?.downloadedCert?.cert?.isSMIME ?? false) {
                    if let hotURl = URL.init(string: service.Uri!) {
                        NSWorkspace.shared.open(hotURl)
                        
                    }
                }
            }
        }
    }
    //MARK:- Timer or Delay handling
    
    /**
     This method is used to handle the view when the delay is encountered.
     in this the timer will be updated and the view will be updated accordingly.
     */
    private func handleAfterDelay(_ isTimerStarted:Bool) {
        //if timer is  already started.
        if isTimerStarted {
            if delayTimeInSeconds > 0 {
                //This will decrement(count down)the seconds.
                delayTimeInSeconds -= 1
                //disable the authentication button.
                setLoginBtn(true)
            } else {
                //stops the timer.
                timer.invalidate()
                timer = Timer()
                isTimerRunning = false
                self.delayTimeInSeconds = 0
                
                //enables the authentication button.
                setLoginBtn(false)
            }
        } else {
            setLoginBtn(false)
        }
        
    }
    
    /**
     This will enable the authentication button, according to the working of the timer.
     - Parameter isWaiting: A bool value, indication the running of the timer.
     */
    private func setLoginBtn(_ isWaiting:Bool) {
        if isWaiting {
            //if the timer is running, then the button will be disabled, and updated with the delay time left.
            lLoginButton?.isEnabled = false
            let waitString = "wait_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            lLoginButton?.title? = "\(waitString)- \(delayTimeInSeconds)s"
        } else {
            //if timer is stopped or invalidate, then the button will be enabled.
            lLoginButton?.isEnabled = true
           // lLoginButton?.title? = "login_button_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
            lLoginButton?.title? = "Next".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        }
    }
    
    /**
     This method is used to schedule the Timer with time duration equal to the delay time encountered.
     - Parameter delay: The time duration for which the timer needs to be scheduled.
     */
    private func runTimer(delay : Int) {
        //global value is set.
        self.delayTimeInSeconds = delay
        
        //checks , wheather timer is running or not.
        if isTimerRunning == false {
            isTimerRunning = true
            DispatchQueue.main.async {
                self.timer.invalidate()
                //schedules the timer with the delay time duration.
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
            }
        }
    }
    
    /**
     This method check , wheather the timer should be continued or not.
     In this when a user encounters a delay for a particular service, then the timer will be scheduled, but they can still use other services other than the one which got delay as a response. So  for other services, timer should not be continued.
     */
    private func shouldTimerContinue() {
        //checks, if the previous selected and current selected service matches.
        if currentSelectedService == lastSelectedService {
            //if matches, then timer should continue.
            setLoginBtn(isTimerRunning)
        } else {
            //if not, then timer is stopped.
            if isTimerRunning {
                isTimerRunning = false
                setLoginBtn(isTimerRunning)
            }
        }
    }
    
    /**
     Sets the Timer, with the delay encountered by the user.
     - Parameter delay: the time the timer needs to be scheduler for a delay.
     */
    private func setTimerWithDelay(delay : Int) {
        Utilities.init().logger.write("delay encountered by the user")
        //executes when the timer is in invalidate state or not running.
        if !isTimerRunning {
            //starts the timer.
            runTimer(delay: delay)
        }
    }
    
    
    //MARK:- OBJC Methods
    /**
     Action/Target method to be called, to Update the timer with the updated delay time.
     */
    @objc func updateTimer() {
        handleAfterDelay(isTimerRunning)
    }
    
    
    //MARK:- Public Methods
    /**
     This method is used to reset the view to its default or initial state.
     With all the variables being initialized to its default value.
     
     - Parameter aServicesArray: A bool value, indicating wheather to delete or reset all the services or not.
     - Parameter username : The username value needed to be displayed on the username textfield
     */
    func resetAll(aServicesArray: Bool,username: String?) {
        DispatchQueue.main.async {
         //   self.lPasswordTextField.stringValue = ""
            self.lUserNameTextField.stringValue = username ?? ""
            
            
        }
    }
    
    /**
     This method is used to retrive the user reponse , according to the challenge encountered.
     - Parameter userResponse:The response of the user corresponding to the challenge faced.
     */
    func challengePopUpOkClicked(_ userResponse: String) {
        //creating the response array.
        let challengeModelArr = [ChallengeModel.init(message: challengeMessage, response: userResponse)]
        let challengeUserModel = ChallengeUserResponse.init(challenges: challengeModelArr)
        
        let jsonData = try! JSONEncoder().encode(challengeUserModel)
        let jsonChallengeStr = String.init(data: jsonData, encoding: .utf8)
        gChallengeModelStr = jsonChallengeStr
        
        //calls for challenge authentication.
        vcmodel.requestForApiService(urlType: .challenge)
        }
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}



