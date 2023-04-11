//
//  Utils.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation


func sec( block: @autoclosure () -> OSStatus) -> Status {
  return Status(rawValue: block())
}


public enum Status {
  case Success
  case Param
  case ItemNotFound
  case AuthorizationDenied
  case AuthorizationCanceled
  case AuthorizationInteractionNotAllowed
  case Other(OSStatus)
  
  init(rawValue: OSStatus) {
    switch rawValue {
    case 0: self = .Success
    case -50: self = .Param
    case -25300: self = .ItemNotFound
    case -60005: self = .AuthorizationDenied
    case -60006: self = .AuthorizationCanceled
    case -60007: self = .AuthorizationInteractionNotAllowed
    default: self = .Other(rawValue)
    }
  }
}
