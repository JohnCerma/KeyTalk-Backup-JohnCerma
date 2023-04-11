//
//  importRCCDViewController.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Cocoa

class importRCCDViewController:  NSViewController, NSTextFieldDelegate {

//MARK:- IBOutlets
    @IBOutlet weak var mUrlTextField: NSTextField!
    @IBOutlet weak var mImageView: NSImageView!

//MARK:- OverrideMethods
    /**
     Method is an override method, called after the view controller’s view has been loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        mImageView.image = #imageLiteral(resourceName: "logo")
        self.mUrlTextField.delegate = self
        mUrlTextField.resignFirstResponder()
    }
    
//MARK:- NSTextFielsDelegateMethod
    /**
     Method is an NSTextField delegate method, returns the controll to the private method on clicking enter.
     */
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        importFromURLActionButton(self)
        return true
    }

//MARK:- IBActions
    /**
     ActionButton is used to import RCCD file from URL.
     */
    @IBAction func importFromURLActionButton(_ sender: Any) {
        let viewController = ViewController()
        viewController.importFromURL(stringValue: mUrlTextField.stringValue)
    }
}
