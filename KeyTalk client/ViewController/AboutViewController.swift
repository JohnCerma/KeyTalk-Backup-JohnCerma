//
//  AboutViewController.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import AppKit

class AboutWindowController: NSWindowController {
}

//MARK:- AboutViewController
class AboutViewController: NSViewController, NSTextFieldDelegate{
//MARK:- IBOutlets
    @IBOutlet weak var mOpenURL: NSButton!
    @IBOutlet weak var mSendMail: NSButton!
    @IBOutlet weak var mVersionLabel: NSTextFieldCell!
    
//MARK:- OverrideMethods
    /**
     Method is an override method, called when the view controller’s view is fully transitioned onto the screen.
     */
    override func viewDidAppear() {
    super.viewDidAppear()
        
  }

    /**
     Method is an override method, called after the view controller’s view has been loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let VersionString = "Version_string".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        mVersionLabel.stringValue = "\(VersionString) \(String(describing: (Bundle.main.releaseVersionNumber)!)).\(String(describing: (Bundle.main.buildVersionNumber)!))"
        //attributed title of URL and Mail button
        mOpenURL.attributedTitle = NSAttributedString(string: "https://www.keytalk.com/",  attributes:  [ NSAttributedString.Key.foregroundColor: NSColor.systemBlue])
        mSendMail.attributedTitle = NSAttributedString(string: "support@keytalk.com",  attributes:  [ NSAttributedString.Key.foregroundColor: NSColor.systemBlue])
        //LocalizerOfApp.DoTheMagic()
    }
    
//MARK:- IBActions
    /**
     ActionButton used to open KeyTalk URL on the browser.
     */
    @IBAction func mOpenURL(_ sender: Any) {
        NSWorkspace.shared.open(URL(string:"https://www.keytalk.com/")!)
    }
    
    /**
     ActionButton used to compose mail along with log file.
     */
    @IBAction func mSendMail(_ sender: Any) {
        //get the path of log file
        let lLogPath = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let lDocumentDirectoryPath = lLogPath.first!
        let lLogFile = lDocumentDirectoryPath.appendingPathComponent("KeyTalk client.log")
        
        let lEmailID = ""
        let lLogFileURL = URL(fileURLWithPath: lLogFile.path)
        
        let lNSSharingService = NSSharingService(named: NSSharingService.Name.composeEmail)
        lNSSharingService?.recipients = [lEmailID] //could be more than one
        lNSSharingService?.subject = EMAIL_REPORT_SUBJECT
        let lItems: [Any] = [EMAIL_REPORT_HTML, lLogFileURL]
        //compose email with log file attached
        lNSSharingService?.perform(withItems: lItems)
    }
}
