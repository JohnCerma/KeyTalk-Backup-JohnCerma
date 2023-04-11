//
//  Localizer.swift
//  KeyTalk client
//
//  Created by  IntiMac on 10/01/19.
//  Copyright © 2019 KeyTalk. All rights reserved.
//

import Foundation
import Cocoa

class LocalizerOfApp : NSObject {
    class func LocalizeStoryboard() {
        
        MethodSwizzleGivenClassName(cls: Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(_:value:table:)))
    }
}

extension Bundle {
    @objc func specialLocalizedStringForKey(_ key: String, value: String?, table tableName: String?) -> String {
        var bundle : Bundle?
        //bundle = Bundle();
        
        if let path =  Bundle.main.path(forResource: LanguageChange.currentAppleLanguageFull(), ofType: "lproj") {
            bundle = Bundle(path: path)!
        } else {
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            bundle = Bundle(path: path!)
        }
        return (bundle?.specialLocalizedStringForKey(key, value: value, table: tableName))!

}
}

func MethodSwizzleGivenClassName(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    let origMethod: Method = class_getInstanceMethod(cls, originalSelector)!
    let overrideMethod: Method = class_getInstanceMethod(cls, overrideSelector)!
    if (class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}
