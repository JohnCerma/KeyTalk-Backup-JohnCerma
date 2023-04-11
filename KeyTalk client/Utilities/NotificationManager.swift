//
//  NotificationManager.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import AppKit

private let _NotificationManager = NotificationManager()

class NotificationManager : NSObject, NSUserNotificationCenterDelegate {
    //MARK:- Class Methods
    class func sharedManager() -> NotificationManager {
        return _NotificationManager
    }
    
    //MARK:- Public Methods
    /**
     This method is used to show notification with action buttons.
     - Parameter informativeText: the String value containing the text that needs to be shown on the notification.
     - Parameter identifier: the String value containing the identifier for notification.
     */
    func showActionNotification( informativeText: String?, identifier: String?){
        let notification = NSUserNotification()
        //set notification attributes
        notification.title = "KeyTalk client"
        notification.informativeText = informativeText
        notification.deliveryDate = Date()
        notification.hasActionButton = true
        notification.actionButtonTitle = "open_KeyTalk_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as? String ?? "en")
        notification.otherButtonTitle = "close_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as? String ?? "en")
        notification.identifier = identifier
        NSUserNotificationCenter.default.delegate = self
        
        NSUserNotificationCenter.default.scheduleNotification(notification)
        
    }
    
    /**
     This method is used to show notification without action buttons.
     - Parameter informativeText: the String value containing the text that needs to be shown on the notification.
     */
    func showNotification( informativeText: String){
        let notification = NSUserNotification()
        //set notification attributes
        notification.title = "KeyTalk client"
        notification.informativeText = informativeText
        notification.deliveryDate = Date()
        notification.hasActionButton = false
        notification.otherButtonTitle = "close_string".localizedNotify(UserDefaults.standard.value(forKey: "LanguageChangeSelected") as! String)
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }
    
    /**
     This method is used to send to the delegate when the user notification center has decided not to present your notification..
     - Parameter center: The user notification center..
     - Parameter notification: The user notification object.
     - Returns: true if the user notification should be displayed regardless; false otherwise..
     */
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    /**
     This method is used to send to the delegate when a user clicks on a user notification presented by the user notification center.
     - Parameter center: The user notification center.
     - Parameter notification: The user notification object.
     */
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!)
        if apps.count == 0 {
        NSWorkspace.shared.launchApplication(Bundle.main.bundlePath)
        NSApplication().activate(ignoringOtherApps: true)
        }
    }
}

extension String {
    func localizedNotify(_ lang:String) ->String {
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }}

