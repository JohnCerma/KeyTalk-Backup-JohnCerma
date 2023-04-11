//
//  HWSignature.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import SystemConfiguration
import IOKit
import SwiftUI

//MARK:- Enum
public enum Component_ID: Int {
    case Predefined = 0         // Shared value between platforms.
    case error_code = 500       // parse error indicator intentionally outside our range (i.e. ignore)
    case UDID = 501             // Unique device Identifier deprecated in iOS 5
    case BundleIdentifier = 502 // Software bundle ID (client App ID)
    case HwModel = 503          // Device hardware model
    case MacAddress = 504       // MAC address of primary interface
    case CPU_Information = 505    // CPU information of the device
    case SerialNumber = 506       //Serial number of the device
    case RandomNumber = 599
    case sentinel = 600          // end of defined ID markers keep as last.
}

let HWSIG_PREDEFINED = "000000000000"
let HWSIG_RANGE_START = 501
let HWSIG_RANGE_END = 600

//MARK:-
class HWSIGCheck {
    //MARK:- Class Methods
    
    /**
     This method is used to check whether the Hardware Signature component is valid or not.
     - Parameter Component_ID: the component ID of the Hardware signature.
     - Returns: A Bool value determining the validity of the Hardware Signature Component.
     */
    class func isValidHwSigComponent(_ i: Component_ID) -> Bool {
        do {
            //checks if the component lies in the pre-defined range
            return try (i == Component_ID.Predefined) || (UInt64(Component_ID.error_code.rawValue) < UInt64(i.rawValue) && UInt64(i.rawValue) < UInt64(Component_ID.sentinel.rawValue))
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    /**
     This method is used whenever a Hardware Signature Component needs to be ignored.
     - Parameter Component_ID: the component ID of the Hardware signature.
     - Returns: A Bool value determining whether to ifnore the Hardware Signature Component or not.
     */
    class func shouldIgnoreHwSigComponent(_ i: Component_ID) -> Bool {
        //checks if the component lies in the pre-defined range
        return (i == Component_ID.error_code) || (HWSIG_RANGE_END < i.rawValue) || ((i != Component_ID.Predefined) && (i.rawValue < HWSIG_RANGE_START))
    }
    
    /**
     This method is used to call the Hardware Signature Component.
     - Parameter Component_ID: the component ID of the Hardware signature.
     - Returns: A String value containing the Component ID.
     */
    class func getComponent(_ componentID: Component_ID) -> String? {
        return self.getComponent(componentID, from: GDevice.init())
    }
    
    /**
     This method is used to get the value of Hardware Signature Component from device corresponding to the ID.
     - Parameter Component_ID: the component ID of the Hardware signature.
     - Parameter from: the device from which values are to be retrieved.
     - Returns: A String value corresponding to the Component ID.
     */
    class func getComponent(_ componentID: Component_ID, from: GDevice) -> String? {
        switch componentID {
        case .Predefined:
            return HWSIG_PREDEFINED
        case .UDID:
            return self.getSystemUUID()
        case .BundleIdentifier:
            return Bundle.main.bundleIdentifier
        case .HwModel:
            return self.getHWModel()
        case .MacAddress:
            return self.calculateMACAddress()
 
        case .error_code: return nil;
        case .sentinel: return nil;
        case .CPU_Information:
            return platform()
        case .SerialNumber:
            return getSerialNumber()
        case .RandomNumber:
            return getRandomNumber()
        }
        
    }
    
    /**
     This method is used to calculate the MAC address of the device.
     - Returns: A String value containing the MAC address of the device.
     */
    class func calculateMACAddress() -> String{
        let macAddress = getMACAddress() as! String
        return macAddress
    }
    
    /**
     This method is used to get the MAC address of the device.
     - Returns: A String value containing the MAC address of the device.
     */
  class func getMACAddress() -> String{
    var macAddressAsString = ""
        if let intfIterator = FindEthernetInterfaces() {
            if let macAddress = GetMACAddress(intfIterator) {
                 macAddressAsString = macAddress.map( { String(format:"%02x", $0) } )
                    .joined(separator: ":")
                print(macAddressAsString)
            }
            
            IOObjectRelease(intfIterator)
        }
    return macAddressAsString
    }
    
    /**
     This method is used to find the Ethernet interfaces of the device.
     - Returns: A io_iterator_t value containing the Ethernet interfaces of the device.
     */
    class func FindEthernetInterfaces() -> io_iterator_t? {
        
        let matchingDict = IOServiceMatching("IOEthernetInterface") as NSMutableDictionary
        matchingDict["IOPropertyMatch"] = [ "IOPrimaryInterface" : true]
        
        var matchingServices : io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &matchingServices) != KERN_SUCCESS {
            return nil
        }
        
        return matchingServices
    }
    
    /**
     This method is used to calculate the MAC address of the device.
     - Returns: A String value containing the MAC address of the device.
     */
    class func GetMACAddress(_ intfIterator : io_iterator_t) -> [UInt8]? {
        
        var macAddress : [UInt8]?
        
        var intfService = IOIteratorNext(intfIterator)
        while intfService != 0 {
            
            var controllerService : io_object_t = 0
            if IORegistryEntryGetParentEntry(intfService, "IOService", &controllerService) == KERN_SUCCESS {
                
                let dataUM = IORegistryEntryCreateCFProperty(controllerService, "IOMACAddress" as CFString, kCFAllocatorDefault, 0)
                if let data = dataUM?.takeRetainedValue() as? NSData {
                    macAddress = [0, 0, 0, 0, 0, 0]
                    data.getBytes(&macAddress!, length: macAddress!.count)
                }
                IOObjectRelease(controllerService)
            }
            
            IOObjectRelease(intfService)
            intfService = IOIteratorNext(intfIterator)
        }
        
        return macAddress
    }
    
    /**
     This method is used to get the Serial Number of the device.
     - Returns: A String value containing the Serial Number of the device.
     */
    class func getSerialNumber() -> String {
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0)
        let serial = serialNumberAsCFString?.takeRetainedValue() as! String
        IOObjectRelease(platformExpert)
        
        return serial
    }
    
    /**
     This method is used to get the System UUID of the device.
     - Returns: A String value containing the System UUID of the device.
     */
    class func getSystemUUID() -> String? {
        let dev = IOServiceMatching("IOPlatformExpertDevice")
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, dev)
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0)
        IOObjectRelease(platformExpert)
        let ser: CFTypeRef = serialNumberAsCFString!.takeUnretainedValue()
        if let result = ser as? String {
            return result
        }
        return nil
    }
    
    /**
     This method is used to get the Random Number of the device.
     - Returns: A String value containing the Random Number of the device.
     */
    class func getRandomNumber() -> String {
        var uuid = ""
        if let randomNumber = UserDefaults.standard.value(forKey: "RandomNumber") {
            uuid = randomNumber as! String
        } else {
            uuid = NSUUID().uuidString
            UserDefaults.standard.set(uuid, forKey: "RandomNumber")
        }
        return uuid
    }
    
    /**
     This method is used to get the HardWare Model of the device.
     - Returns: A String value containing the HardWare Model of the device.
     */
    class func getHWModel() -> String? {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }

    /**
     This method is used to get the platform of the device.
     - Returns: A String value containing the platform of the device.
     */
   class func platform() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0,  count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    /**
     This method is used to get the Component Name of the Hardware Signature Component.
     - Parameter Component_ID: the component ID of the Hardware signature.
     - Returns: A String value containing the Component Name of the Hardware Signature Component.
     */
    class func getComponentName(_ componentId: Component_ID) -> String? {
        switch componentId {
        case .Predefined:
            return "Predefined"
        case .UDID:
            return "UDID"
        case .BundleIdentifier:
            return "Bundle identifier"
        case .HwModel:
            return "Hardware model"
        case .MacAddress:
            return "MAC address"
        case .error_code:
            return nil
        case .sentinel:
            return nil
        case .CPU_Information:
            return "CPU information"
        case .SerialNumber:
            return "Serial number"
        case .RandomNumber:
            return "Random number"
        }
    }
}
//MARK:-
class HWSIGCalc {
    
    //MARK:- Class Methods
    
    /**
     This method is used to save the Hardware signature Formula.
     - Parameter formula: the string value containing the formula of the Hardware Signature.
     */
    class func saveHWSIGFormula(formula: String) {
        UserDefaults.standard.set(formula, forKey: "hwsigformula")
    }
    
    /**
     This method is used to parse the Hardware signature Formula.
     - Parameter formula: the string value containing the formula of the Hardware Signature.
     - Returns: An array of NSNumber containing the parsed Hardware Signature.
     */
    private class func parseHWSIGFormula(formula: String) -> [NSNumber] {
        let tokens = formula.components(separatedBy: ",")
        let whites = CharacterSet.whitespacesAndNewlines
        let formatter = NumberFormatter()
        
        var arr = [NSNumber]()
        
        for s in tokens {
            let x = formatter.number(from: s.trimmingCharacters(in: whites))
            var value = Component_ID.error_code.rawValue
            if let x = x {
                value = x.intValue
            }
            let id = Component_ID(rawValue: value)
            if let id = id {
                if !HWSIGCheck.shouldIgnoreHwSigComponent(id) {
                    arr.append(NSNumber.init(value: HWSIGCheck.isValidHwSigComponent(id) ? id.rawValue : Component_ID.Predefined.rawValue))
                }
            }
        }
        if arr.count == 0 {
            arr.append(NSNumber.init(value: Component_ID.Predefined.rawValue))
        }
        return arr
    }
    
    /**
     This method is used to get the Hardware Signature Formula.
     - Returns: A String value containing the Hardware Signature Formula.
     */
    private class func getHWSIGFormula() -> String {
        var formula = ""
        var str = UserDefaults.standard.value(forKey: "hwsigformula") as? String
        if let str = str {
            formula = str
        }
        return formula
    }
    
    /**
     This method is used to calculate the Hardware Signature Formula.
     - Returns: A String value containing the Hardware Signature Formula.
     */
    class func calcHwSignature() -> String {
        //get actual formula for Hardware Signature
        let actualFormula = parseHWSIGFormula(formula: getHWSIGFormula())
        var components = [String]()
        for number in actualFormula {
            let compIDInt = number.intValue
            let compIDType = Component_ID.init(rawValue: compIDInt)
            if let compIDType = compIDType {
                let componentName = HWSIGCheck.getComponentName(compIDType)
                let componentValue = HWSIGCheck.getComponent(compIDType)
                print("Component name and value", componentName!, componentValue!)
                components.append(componentValue!)
            }
        }
        let hwSigStr = components.joined(separator: "")
        return hwSigStr
    }
    
    
}
