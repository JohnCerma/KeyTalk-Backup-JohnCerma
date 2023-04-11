//
//  AppDelegate.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.

import Cocoa
import CoreData
import Foundation
import ServiceManagement
import Security
import AppKit

class AppMenu: NSMenu {
}

@available(OSX 10.14, *)
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSMenuItemValidation {
    
    @IBOutlet weak var KeyTalkClientMenuItem: NSMenuItem!
    @IBOutlet weak var HelpMenuItem: NSMenuItem!
    @IBOutlet weak var WindowMenuItem: NSMenuItem!
    @IBOutlet weak var ViewMenuItem: NSMenuItem!
    @IBOutlet weak var AboutKTMenuItem: NSMenuItem!
    @IBOutlet weak var HideKTMenuItem: NSMenuItem!
    @IBOutlet weak var HideOtherMenuItem: NSMenuItem!
    @IBOutlet weak var ShowAllMenuItem: NSMenuItem!
    @IBOutlet weak var QuitKTMenuItem: NSMenuItem!
    @IBOutlet weak var UndoMenu: NSMenuItem!
    @IBOutlet weak var RedoMenuItem: NSMenuItem!
    @IBOutlet weak var CutMenuItem: NSMenuItem!
    @IBOutlet weak var CopyMenuItem: NSMenuItem!
    @IBOutlet weak var PasteMenuItem: NSMenuItem!
    @IBOutlet weak var PasteandMatchMenuItem: NSMenuItem!
    @IBOutlet weak var DeleteMenuItem: NSMenuItem!
    @IBOutlet weak var SelectAllMenuItem: NSMenuItem!
    @IBOutlet weak var FindMenuItem: NSMenuItem!
    @IBOutlet weak var SpellGrammerMenuItem: NSMenuItem!
    @IBOutlet weak var SubstitutionMenuItem: NSMenuItem!
    @IBOutlet weak var TransformationMenuItem: NSMenuItem!
    @IBOutlet weak var SpeechMenuItem: NSMenuItem!
    
    @IBOutlet weak var findSubMenuItem: NSMenuItem!
    @IBOutlet weak var findReplaceSubMenuItem: NSMenuItem!
    @IBOutlet weak var FindNextSubMenuItem: NSMenuItem!
    @IBOutlet weak var FindpreviousSubMenuItem: NSMenuItem!
    @IBOutlet weak var FindSelectionSubMenuItem: NSMenuItem!
    @IBOutlet weak var JumpsubMenuItem: NSMenuItem!
    @IBOutlet weak var ShowSpellMenuSubItem: NSMenuItem!
    @IBOutlet weak var CheckDocSubMenuItem: NSMenuItem!
    @IBOutlet weak var CheckSpellSubMenuItem: NSMenuItem!
    @IBOutlet weak var CheckGrammerSubMenuItem: NSMenuItem!
    @IBOutlet weak var CorrectSpellSubMenuItem: NSMenuItem!
    @IBOutlet weak var ShowSubstituionSubMenuItem: NSMenuItem!
    @IBOutlet weak var SmartCPSubMenuItem: NSMenuItem!
    @IBOutlet weak var SmartQSubMenuItem: NSMenuItem!
    @IBOutlet weak var SmartDSubMenuItem: NSMenuItem!
    @IBOutlet weak var SmartLSubMenuItem: NSMenuItem!
    @IBOutlet weak var DataDSubMenuItem: NSMenuItem!
    @IBOutlet weak var TextRSubMenuItem: NSMenuItem!
    @IBOutlet weak var MakeUCSubMenuItem: NSMenuItem!
    @IBOutlet weak var MakeLCSubMenuItem: NSMenuItem!
    @IBOutlet weak var CapatilizeSubMenuItem: NSMenuItem!
    @IBOutlet weak var StartSpeakSubMenuItem: NSMenuItem!
    @IBOutlet weak var StopSpeakSubMenuItem: NSMenuItem!
    @IBOutlet weak var ShowTMenuItem: NSMenuItem!
    @IBOutlet weak var CustomizeTMenuItem: NSMenuItem!
    @IBOutlet weak var ShowSideMenuItem: NSMenuItem!
    @IBOutlet weak var MinimizeMenuItem: NSMenuItem!
    @IBOutlet weak var BringTFMenuItem: NSMenuItem!
    @IBOutlet weak var KTclientHelpMenuItem: NSMenuItem!
    
    //MARK:- Variables
    //initializes the MenuItems for validation
    lazy var appMenu: NSMenu = {
        return NSMenu()
    }()
    lazy var crlMenu: NSMenu = {
        return NSMenu()
    }()
    lazy var changeLangMenu: NSMenu = {
        return NSMenu()
    }()
    lazy var statusItem = {
        return NSStatusBar.system.statusItem(withLength: -1)
    }()
    var crlItem: NSMenuItem!
    var changeLangItem: NSMenuItem!
    
    //shows the icon on the status bar when the app is running.
    lazy var statusImageRunning: NSImage = {
        let  statusImage: NSImage = NSImage(named:NSImage.Name("AppIcon"))!;
        statusImage.size = NSMakeSize(18.0, 18.0);
        return statusImage
    }()
    
    //UserDefaults to store launch options and crl frequency
    lazy var userDefaults: UserDefaults =  {
        return UserDefaults.standard
    }()
    
    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        item.title = "\(item.title)\(index)"
        return true
    }
    //MARK:- OverrideMethods
    
    /**
     Method is an override method, used to validate the items that are added to the Menu.
     */
   
      func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        var isMenuValidated = false
        
        if(menuItem.action==#selector(AppDelegate.startAtLoginItem(_:))) {
            let isStartAtLogin = LoginDBHandler.getIsStartAtLoginEnabled() ?? false
            switch isStartAtLogin /*userDefaults.bool(forKey: "launchAtLogin")*/ {
            case true:
                menuItem.state=NSControl.StateValue.on;
            case false:
                menuItem.state=NSControl.StateValue.off;
            }
            isMenuValidated = true
            
        } else     if menuItem.action == #selector(AppDelegate.quit(_:)) {
            isMenuValidated = true
        }
        else if menuItem.action == #selector(AppDelegate.showLogs(_:)) {
            isMenuValidated = true
        }
        else if menuItem.action == #selector(AppDelegate.sendLogs(_:)) {
            isMenuValidated = true
        }
        else if menuItem.action == #selector(AppDelegate.showAbout(_:)) {
            isMenuValidated = true
        }
        else if menuItem.action == #selector(AppDelegate.removeAllCerificates(_:)) {
            isMenuValidated = true
        }
        else if menuItem.action == #selector(AppDelegate.removeAllConfigurations(_:)) {
            isMenuValidated = true
        }else if menuItem.action == #selector(AppDelegate.checkCRLFrequencyTime(_:)) {
            var userDefaultValue = userDefaults.value(forKey: "crlFrequency") as? String
            if userDefaultValue == nil  {
                userDefaultValue = "24 hours"
            }
            if menuItem.title == userDefaultValue {
                menuItem.state = NSControl.StateValue.on
            }
            isMenuValidated = true
        } else if (menuItem.action == #selector(AppDelegate.changeLanguageOnclick(_:))) {
            var userDefaultValue = userDefaults.value(forKey: "LanguageSelected") as? String
            if userDefaultValue == nil  {
                userDefaultValue = "English"
            }
            if menuItem.title == userDefaultValue {
                menuItem.state = NSControl.StateValue.on
            }
            isMenuValidated = true
        }else if (menuItem.action == #selector(AppDelegate.openHelp(_:))) {
            isMenuValidated = true
        }
        
        return isMenuValidated
    }
    
    /**
     Method is an override method, called when NSStatusBar Item is clicked.
     */
    func menuWillOpen(_ menu: NSMenu) {
        LocalizerOfApp.LocalizeStoryboard()
        var apps = NSRunningApplication.runningApplications(withBundleIdentifier: "\(Bundle.main.bundleIdentifier!)")
        apps[0].activate(options: .activateIgnoringOtherApps)
        NSApplication.shared.windows[0].makeKeyAndOrderFront(menu)
        
    }
    
    /**
     Method is an NSApplicationDelegate method, it is called as soon as the app is about to launch.
     */
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApplication.shared.windows[0].standardWindowButton(.zoomButton)?.isHidden = true
    }
    
    /**
     Method is an NSApplicationDelegate method, it is called as soon as the app is launched.
     */
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        do {
            var enabled: Bool
            if let SMLoginValue = LoginDBHandler.getIsStartAtLoginEnabled() {
                enabled = SMLoginValue
            } else {
                enabled = false
            }
            let helperBundleName = "com.keytalk.LauncherApp"
            SMLoginItemSetEnabled(helperBundleName as CFString, enabled)
            //set image for NSMenu
         
            
            appMenu.delegate = self
            LocalizerOfApp.LocalizeStoryboard()
            HelpMenuItem.title = "help_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            ViewMenuItem.title = "view_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            WindowMenuItem.title = "window_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            AboutKTMenuItem.title = "about_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            HideKTMenuItem.title = "hideKT_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            HideOtherMenuItem.title = "hideOther_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            ShowAllMenuItem.title = "Show_all_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            QuitKTMenuItem.title = "quitKT_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            UndoMenu.title = "undo_title".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            RedoMenuItem.title = "redo_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            CutMenuItem.title = "cut_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            CopyMenuItem.title = "copy_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            PasteMenuItem.title = "paste_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            PasteandMatchMenuItem.title = "paste_match_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            DeleteMenuItem.title = "delete_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            SelectAllMenuItem.title = "select_all_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            FindMenuItem.title = "find_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            SpellGrammerMenuItem.title = "spelling_grammer_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            SubstitutionMenuItem.title = "substituion_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            TransformationMenuItem.title = "tranformation_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            SpeechMenuItem.title = "speech_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            findSubMenuItem.title = "find_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            findReplaceSubMenuItem.title = "find_replace_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            FindNextSubMenuItem.title = "find_next_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            FindpreviousSubMenuItem.title = "find_previous_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            FindSelectionSubMenuItem.title = "use_selection_find_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            JumpsubMenuItem.title = "jump_selection".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            ShowSpellMenuSubItem.title = "show_sg_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            CheckDocSubMenuItem.title = "check_doc_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            CheckSpellSubMenuItem.title = "check_swt_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            CheckGrammerSubMenuItem.title = "check_gws_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            CorrectSpellSubMenuItem.title = "spell_auto_submenu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            //ShowSubstituionSubMenuItem.title = "show_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            SmartCPSubMenuItem.title = "smart_cp_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            SmartQSubMenuItem.title = "smart_quote_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            SmartDSubMenuItem.title = "smart_dash_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            SmartLSubMenuItem.title = "smart_link_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            DataDSubMenuItem.title = "data_detectors_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            TextRSubMenuItem.title = "text_replacement_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            MakeUCSubMenuItem.title = "make_uc_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            MakeLCSubMenuItem.title = "make_lc_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            CapatilizeSubMenuItem.title = "captalize_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            StartSpeakSubMenuItem.title = "start_speak_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            StopSpeakSubMenuItem.title = "stop_speak_sub".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            ShowTMenuItem.title = "show_toolbar_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            CustomizeTMenuItem.title = "customize_toolbar_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            ShowSideMenuItem.title = "show_sidebar_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            MinimizeMenuItem.title = "minimize_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            BringTFMenuItem.title = "bring_to_front_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            KTclientHelpMenuItem.title = "KThelp_menu".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String)
            statusItem.image = statusImageRunning
            statusItem.isVisible = true
            statusItem.menu = appMenu
            
            
            //add the menu items and their corresponding actions.
            appMenu.addItem(NSMenuItem(title: "remove_cert_string".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: #selector(AppDelegate.removeAllCerificates(_:)), keyEquivalent: ""))
            appMenu.addItem(NSMenuItem(title: "remove_config_string".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: #selector(ViewController.removeAllConfigurations(_:)), keyEquivalent: ""))
            appMenu.addItem(NSMenuItem.separator())
            appMenu.addItem(NSMenuItem(title: "start_at_login_string".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: #selector(AppDelegate.startAtLoginItem(_:)), keyEquivalent: ""))

            changeLangItem = NSMenuItem(title: "change_language_string".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: nil, keyEquivalent: "")
            appMenu.addItem(changeLangItem)
            appMenu.setSubmenu(changeLangMenu, for: changeLangItem)
            changeLangMenu.addItem(NSMenuItem(title: "English", action: #selector(AppDelegate.changeLanguageOnclick(_:)), keyEquivalent: ""))
            changeLangMenu.addItem(NSMenuItem(title: "German", action: #selector(AppDelegate.changeLanguageOnclick(_:)), keyEquivalent: ""))
            changeLangMenu.addItem(NSMenuItem(title: "French", action: #selector(AppDelegate.changeLanguageOnclick(_:)), keyEquivalent: ""))
            changeLangMenu.addItem(NSMenuItem(title: "Dutch", action: #selector(AppDelegate.changeLanguageOnclick(_:)), keyEquivalent: ""))

            crlItem = NSMenuItem(title: "Check CRL".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: nil, keyEquivalent: "")
            appMenu.addItem(crlItem)
            appMenu.setSubmenu(crlMenu, for: crlItem)
            crlMenu.addItem(NSMenuItem(title: "1 hour", action: #selector(AppDelegate.checkCRLFrequencyTime(_:)), keyEquivalent: ""))
            crlMenu.addItem(NSMenuItem(title: "3 hours", action: #selector(AppDelegate.checkCRLFrequencyTime(_:)), keyEquivalent: ""))
            crlMenu.addItem(NSMenuItem(title: "24 hours", action: #selector(AppDelegate.checkCRLFrequencyTime(_:)), keyEquivalent: ""))
            
            updateCRLMenuOnStartUp()
            
            appMenu.addItem(NSMenuItem(title: "show_log_string".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: #selector(AppDelegate.showLogs(_:)), keyEquivalent: ""))
            appMenu.addItem(NSMenuItem(title: "send_log_string".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: #selector(AppDelegate.sendLogs(_:)), keyEquivalent: ""))
            appMenu.addItem(NSMenuItem.separator())
            appMenu.addItem(NSMenuItem(title: "about_string".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: #selector(AppDelegate.showAbout(_:)), keyEquivalent: ""))
            appMenu.addItem(NSMenuItem.separator())
            appMenu.addItem(NSMenuItem(title: "quit_client_string".localized(userDefaults.value(forKey: "LanguageChangeSelected") as! String), action: #selector(AppDelegate.quit(_:)), keyEquivalent: ""))
            
        //activate application
            
            NSApplication().activate(ignoringOtherApps: true)
          
        }
        catch let error {
            Utilities.showAlert(aMessageText: error.localizedDescription)
        }
        
    }
    
    /**
     Method is an NSApplicationDelegate method, Sent by the application to the delegate prior to default behavior to reopen.
     */
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
    
    /**
     Method is an NSApplicationDelegate method, it is called when the app is about to be terminated.
     */
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        PersistenceService.saveContext()
    }
    
    /**
     Method is an NSApplicationDelegate method, it is called when an RCCD file is clicked to open the app.
     */
    func application(_ sender: NSApplication, openFile path: String) -> Bool {
        // name of the RCCD file
        let filename = URL(fileURLWithPath: path).lastPathComponent
        
        //unzips the RCCD file
        Utilities.unZipFile(aPath: path)
        
        //close any old instance of the app
        NSApplication.shared.mainWindow?.close()
        
        var myWindow: NSWindow? = nil
        //instantiate the view from storyboard
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let newController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("KeyTalk client")) as! NSSplitViewController
        myWindow = NSWindow(contentViewController: newController)
        myWindow?.makeKeyAndOrderFront(self)
        let vc = NSWindowController(window: myWindow)
        vc.showWindow(self)
        return true
    }
    
    //MARK:- PrivateMethods
    
    /**
     This method is called when the user selects or de-selects the 'Start At Login' menu item. This methods stores the user selected launch options and performs the tasks as selected.
     - Parameter enabled: The Bool value of the User selected launch options.
     */
    func startAtLogin(enabled: Bool) {
        
        do {
            LoginDBHandler.saveLoginPreferencetoDatabase(isStartAtLoginEnabled: enabled)
            let helperBundleName = "com.keytalk.LauncherApp"
            SMLoginItemSetEnabled(helperBundleName as CFString, enabled)
            Utilities.init().logger.write("SMLoginItemSetEnabled set to \(enabled)")
        } catch {
            Utilities.init().logger.write(error.localizedDescription)
        }
    }
    
    /**
     This method is called when the menu items are being validated, it sets the default value of crl frequency to 24 hours if no other option is stored in user defaults.
     */
    func updateCRLMenuOnStartUp () {
        
        //turn all the frequency items to off
        for i in 0..<crlMenu.items.count {
            crlMenu.items[i].state = NSControl.StateValue.off
        }
        //get the last selected crl frequency value from user defaults
        if let crlFrequencyInterval = userDefaults.value(forKey: "crlFrequency") as? String {
            //turen the last selected frequency on
            switch crlFrequencyInterval {
            case Interval.oneHour.rawValue:
                crlMenu.items[0].state = NSControl.StateValue.on
                break
            case Interval.threeHour.rawValue:
                crlMenu.items[1].state = NSControl.StateValue.on
                break
            case Interval.twentyFourHour.rawValue:
                crlMenu.items[2].state = NSControl.StateValue.on
                break
            default:
                crlMenu.items[2].state = NSControl.StateValue.on
            }
        } else {
            crlMenu.items[2].state = NSControl.StateValue.off
            saveCRLcheckTimetoDB(optionSelected: Interval.twentyFourHour.rawValue)
        }
    }
    
    /**
     This method is called when the user clicks on the 'CRL Frequency' menu item. This methods stores the user selected frequency options and performs the tasks as selected.
     - Parameter enabled: The String value of the User selected Frequency options.
     */
    func saveCRLcheckTimetoDB(optionSelected: String) {
        //get the current time
        let currentTime = NSDate().timeIntervalSinceReferenceDate
        var frequencySelected:Double = 0.0
        var timetoCheck:Double = 0.0
        if optionSelected == Interval.oneHour.rawValue {
            //option selected is 1 hour
            frequencySelected = 3600.0
            timetoCheck = currentTime + frequencySelected
        } else if optionSelected == Interval.threeHour.rawValue {
            //option selected is 3 hours
            frequencySelected = 10800.0
            timetoCheck = currentTime + frequencySelected
        } else if optionSelected == Interval.twentyFourHour.rawValue {
            //option selected is 24 hours
            frequencySelected = 86400.0
            timetoCheck = currentTime + frequencySelected
        } else {
            //default value of crl frquency is 24 hours
            frequencySelected = 86400.0
            timetoCheck = currentTime + frequencySelected
        }
        //save the next crl check time and selected frequency to database
        CRLDBHandler.saveCRLFrequencytoDatabase(timetoCheck: timetoCheck, frequencySelected: frequencySelected)
        Utilities.init().logger.write("CRL frequency set to \(optionSelected)")
    }
    
    //MARK:- NSMenuItem's selector
    /**
     This method is called whenever user clicks on Remove Certificates item.
     */
    @objc func removeAllCerificates(_ sender: AnyObject) {
        //all certificates are removed from the database
        DownloadedCertificateHandler.deleteAllData()
        Utilities.init().logger.write("All certificates deleted from database")
    }
    
    /**
     This method is called whenever user clicks on Remove Configurations item.
     */
    @objc func removeAllConfigurations(_ sender: AnyObject) {
        let vc = ViewController()
        //all RCCD files are removed from the View
        vc.removeAllRCCDFiles()
        Utilities.init().logger.write("All RCCDs removed from database")
    }
    
    /**
     This method is called whenever user clicks on SendAbout item.
     */
    @objc func showAbout(_ sender: AnyObject) {
        //get the about View Controller from storyboard
        let about = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("AboutViewController")
        let vc = about.instantiateController(withIdentifier: identifier) as! AboutViewController
        var myWindow: NSWindow? = nil
        myWindow = NSWindow(contentViewController: vc)
        myWindow?.makeKeyAndOrderFront(self)
        let viewController = NSWindowController(window: myWindow)
        viewController.showWindow(self)
    }
    
    /**
     This method is called whenever user clicks on Show Logs item.
     */
    @objc func showLogs(_ sender: AnyObject) {
//            let task = Process()
        //path for log file in documents directory
        let url = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first?.appendingPathComponent("KeyTalk client.log")
        //= FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("KeyTalk client.log")
        Process.launchedProcess(launchPath: "/usr/bin/open", arguments: ["-a",
                                                                         "TextEdit",
                                                                         url!.path])
//        task.launchPath = "/Applications/Utilities/Console.app/Contents/MacOS/Console"
//        task.arguments = [url!.path]
//        //launch the log file
//        do{
//            try task.run()
//        }catch{
//            print(error.localizedDescription)
//        }
    }
    
    /**
     This method is called whenever user clicks on Send Logs item.
     */
    @objc func sendLogs(_ sender: AnyObject) {
        //path for log file located in documents folder
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent("KeyTalk client.log")
        
        let email = ""
        let fileURL = URL(fileURLWithPath: log.path)
        //compose email to send logs
        let sharingService = NSSharingService(named: NSSharingService.Name.composeEmail)
        sharingService?.recipients = [email] //could be more than one
        sharingService?.subject = EMAIL_REPORT_SUBJECT
        //attach log file to the mail
        let items: [Any] = [EMAIL_REPORT_HTML, fileURL]
        sharingService?.perform(withItems: items)
    }
    
    /**
     This method is called whenever user clicks on Quit item.
     */
    @objc func quit(_ sender: AnyObject) {
        //application is terminated
        NSApplication.shared.terminate(nil)
    }
    
    //MARK:- IBAction for NSMenu Items
    /**
     This method is called whenever user clicks on Start At Login item.
     */
    @IBAction func startAtLoginItem(_ sender: NSMenuItem) {
        //check for user's selection
        switch sender.state.rawValue {
        case 0:
            //if startAtlogin is true
            startAtLogin(enabled: true)
            
        default:
            //if startAtLogin is false
            startAtLogin(enabled: false)
        }
    }
    
    @IBAction func openHelp(_ sender: Any) {
        NSWorkspace.shared.open(URL(string:"https://www.keytalk.com/contact")!)
    }
    
    /**
     This method is called whenever user clicks on CRL Frequency item.
     */
    @IBAction func checkCRLFrequencyTime(_ sender: NSMenuItem) {
        let optionSelected = sender.title
        let stateValue = sender.state.rawValue
        for i in 0..<crlMenu.items.count {
            //turn all the options to false
            crlMenu.items[i].state = NSControl.StateValue.off
        }
        //only the option selected is turned on
        sender.state = NSControl.StateValue.on
        //store the option selected to User Defaults
        userDefaults.set(optionSelected, forKey: "crlFrequency")
        userDefaults.synchronize()
        saveCRLcheckTimetoDB(optionSelected: optionSelected)
        
        switch stateValue {
        case 0:
            print("\(optionSelected) is selected)")//crlCheckFrequency(title: optionSelected)
        default:
            break
        }
    }
    
    /**
     This method is called whenever user clicks on change language item.
     */
    @IBAction func changeLanguageOnclick(_ sender: NSMenuItem) {
        var optionSelected = sender.title
        let stateValue = sender.state.rawValue
        for i in 0..<changeLangMenu.items.count {
            //turn all the options to false
            changeLangMenu.items[i].state = NSControl.StateValue.off
        }
        //only the option selected is turned on
        sender.state = NSControl.StateValue.on
        //store the option selected to User Defaults
        userDefaults.set(optionSelected, forKey: "LanguageSelected")
        switch optionSelected {
        case LanguageEnum.english.rawValue:
            optionSelected = "en"
            case LanguageEnum.German.rawValue:
            optionSelected = "de"
            case LanguageEnum.French.rawValue:
                optionSelected = "fr"
            case LanguageEnum.Dutch.rawValue:
                optionSelected = "nl"
            default:
                optionSelected = "en"
        }
        LanguagePrefrenceDBHandler.saveLanguagePreferencetoDatabase(languageSelected: optionSelected)
        //gLanguageSelected = LanguagePrefrenceDBHandler.getLanguageSelected() ?? "en"
        userDefaults.set(optionSelected, forKey: "LanguageChangeSelected")
//        userDefaults.set(optionSelected, forKey: "AppleLanguages")
        userDefaults.synchronize()

        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
       
    }
    
    
}


//enum for CRL frequencies
public enum Interval : String {
    case oneHour = "1 hour"
    case threeHour = "3 hours"
    case twentyFourHour = "24 hours"
}

public enum LanguageEnum : String {
    case english = "English"
    case German = "German"
    case French = "French"
    case Dutch = "Dutch"
}




extension String {
    func localized(_ lang:String) ->String {
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }}




