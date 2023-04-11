//
//  textLog.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
//MARK:- Structure
struct Logger: TextOutputStream {
    
    //MARK:- Mutating Method
    /// Appends the given string to the stream.
    /**
     This method is used to write entries to Log file
     - Parameter string: the String value containing the log entries to be written in the log file.
     */
    mutating func write(_ string: String) {
        let string1 = "\n Time::::::: \(Utilities.getTimeStamp()) UTC," + string
        //path of log file
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent("KeyTalk client.log")
        
        do {
            //write to log file
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            handle.write(string1.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try string1.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
