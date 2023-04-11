//
//  Language.swift
//  KeyTalk client
//
//  Created by  IntiMac on 10/01/19.
//  Copyright © 2019 KeyTalk. All rights reserved.
//

import Foundation
import Cocoa

// constants
let APPLE_LANGUAGE_KEY = "AppleLanguages"
/// LanguageChange
class LanguageChange {
    /// get current Apple language
    class func currentAppleLanguage() -> String{
        let userdef = UserDefaults.standard
       
        var currentWithoutLocale = "en"
        if let x = userdef.value(forKey: "LanguageChangeSelected") {
            currentWithoutLocale = x as! String
        }
        return currentWithoutLocale
        
//        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
//        let current = langArray.firstObject as! String
//        let endIndex = current.startIndex
//        let currentWithoutLocale = current.substring(to: current.index(endIndex, offsetBy: 2))
//        return currentWithoutLocale
    }
    
    class func currentAppleLanguageFull() -> String {
        let userdef = UserDefaults.standard
//        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
//        let current = langArray.firstObject as! String
        var current = Locale.current.languageCode
        if let x = userdef.value(forKey: "LanguageChangeSelected") {
            current = x as! String
        }
//        return current
        return current!
        
    }
    
    /// set @lang to be the first in Applelanguages list
    class func setAppleLAnguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang,currentAppleLanguage()], forKey: "LanguageChangeSelected")
        userdef.synchronize()
    }
}
