//
//  LDAPGuideViewController.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi on 6/4/19.
//  Copyright © 2019 KeyTalk. All rights reserved.
//

import Foundation
import AppKit

/// Mike Requested for a temporary disabling the LDAP configuaration //////
//
//class LDAPGuideWindowController: NSWindowController {
//}
//
//class LDAPGuideViewController: NSViewController, NSTextFieldDelegate {
//    
//    var wind:NSWindow?
//    
//    @IBOutlet weak var Step1lbl: NSTextField!
//    @IBOutlet weak var Step1imgView: NSImageView!
//    @IBOutlet weak var instructionLbl: NSTextField!
//    
//    //MARK:- OverrideMethods
//    /**
//     Method is an override method, called when the view controller’s view is fully transitioned onto the screen.
//     */
//    override func viewDidAppear() {
//        super.viewDidAppear()
//         wind = self.view.window!
//        wind?.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true
//        wind?.standardWindowButton(NSWindow.ButtonType.zoomButton)!.isHidden = true
//    }
//    
//    @IBAction func clickNext(_ sender: Any) {
//        wind?.close()
//
//    }
//    /**
//     Method is an override method, called after the view controller’s view has been loaded into memory.
//     */
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let x = "step1lbl_text".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
//        Step1lbl.stringValue = "\(x)"
//        instructionLbl.stringValue = "instructionLBL_text".localized(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
//    }
//    
//  
//}
//
//extension LDAPGuideViewController {
//    // MARK: Storyboard instantiation
//    static func freshController() -> LDAPGuideViewController {
//        //1.
//        let storyboard = NSStoryboard(name:"Main", bundle: nil)
//        //2.
//        let identifier = NSStoryboard.SceneIdentifier("LDAPGuideViewController")
//        //3.
//        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? LDAPGuideViewController else {
//            fatalError("Why cant i find LDAPGuideViewController? - Check Main.storyboard")
//        }
//        return viewcontroller
//    }
//}


/// Mike Requested for a temporary disabling the LDAP configuaration //////
