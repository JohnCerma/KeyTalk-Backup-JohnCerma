//
//  AppDelegate.swift
//  LauncherApp
//
//  Created by Rinshi Rastogi on 12/7/18.
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Cocoa

@NSApplicationMain
class HelperAppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        BackgroundScheduler.getSharedInstance().startActivity()
        var startAtLogin = LoginDBHandler.getIsStartAtLoginEnabled() ?? false
        if startAtLogin == true {
            let runningApps = NSWorkspace.shared.runningApplications
            let isRunning = runningApps.contains {
                $0.bundleIdentifier == "com.keytalk.keytalkmacclient"
            }
            
            if !isRunning {
                var url = Bundle.main.bundleURL
                url = url.deletingLastPathComponent()
                url = url.deletingLastPathComponent()
                url = url.deletingLastPathComponent()
                url = url.appendingPathComponent("MacOS", isDirectory: true)
                url = url.appendingPathComponent("KeyTalk client", isDirectory: false)
                NSWorkspace.shared.launchApplication(url.path)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}

