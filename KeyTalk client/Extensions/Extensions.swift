//
//  Extensions.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import AppKit

//MARK:- AboutViewControllerExtension
extension AboutWindowController: NSWindowDelegate {
    private func windowShouldClose(_ sender: Any) -> Bool {
        let lApplication = NSApplication.shared
        lApplication.abortModal()
        return true
    }
}

//To get the version number and build number of the application.
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

//To iterate to the next line of the file
extension StreamReader : Sequence {
    func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}

//To get the status
extension Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Success: return "Status.Success"
        case .Param: return "Status.Param"
        case .ItemNotFound: return "Status.ItemNotFound"
        case .AuthorizationDenied: return "Status.AuthorizationDenied"
        case .AuthorizationCanceled: return "Status.AuthorizationCanceled"
        case .AuthorizationInteractionNotAllowed: return "Status.AuthorizationInteractionNotAllowed"
        case .Other(let status): return "Status.Other(\(status))"
        }
    }
}

