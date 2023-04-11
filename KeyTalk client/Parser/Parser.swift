//
//  Parser.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi 
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation
import Yaml

class Parser {
    
    //MARK:- Public Methods
    
    /**
     This method is used to parse INI string retrieved from the RCCD file
     - Parameter String: The INI string retieved from the RCCD file downloaded.
     */
    public class func parseIni(aIniString: String) -> String {
        
        var lContentString = aIniString
        
        if !lContentString.hasPrefix("{"){
            lContentString = "{" + lContentString
        }
        if !lContentString.hasSuffix("}"){
            lContentString = lContentString + "}"
        }
        
        lContentString = lContentString.replacingOccurrences(of: "\n", with: "")
        lContentString = lContentString.replacingOccurrences(of: "\t", with: "")
        lContentString = lContentString.replacingOccurrences(of: "\r", with: "")
        
        var lRange = lContentString.range(of: "  ")
        while (lRange != nil) {
            lContentString = lContentString.replacingOccurrences(of: "  ", with: " ")
            lRange = lContentString.range(of: "  ")
        }
        
        lContentString = lContentString.replacingOccurrences(of: "://", with: "HACK01")
        lContentString = lContentString.replacingOccurrences(of: ":", with: "HACK02")
        
        lContentString = lContentString.replacingOccurrences(of: " = ", with: ":")
        lContentString = lContentString.replacingOccurrences(of: "= ", with: ":")
        lContentString = lContentString.replacingOccurrences(of: " =", with: ":")
        lContentString = lContentString.replacingOccurrences(of: "=", with: ":")
        
        lContentString = lContentString.replacingOccurrences(of: ";", with: ",")
        lContentString = lContentString.replacingOccurrences(of: "(", with: "[")
        lContentString = lContentString.replacingOccurrences(of: ")", with: "]")
        
        lContentString = lContentString.replacingOccurrences(of: ",}", with: "}")
        lContentString = lContentString.replacingOccurrences(of: ", }", with: "}")
        lContentString = lContentString.replacingOccurrences(of: ",]", with: "]")
        lContentString = lContentString.replacingOccurrences(of: ", ]", with: "]")
        
        lContentString = lContentString.replacingOccurrences(of: ":", with: "\":")
        lContentString = lContentString.replacingOccurrences(of: "{ ", with: "{")
        lContentString = lContentString.replacingOccurrences(of: "{", with: "{\"")
        
        lContentString = lContentString.replacingOccurrences(of: ",{", with: "HACK03")
        lContentString = lContentString.replacingOccurrences(of: ", { ", with: "HACK03")
        lContentString = lContentString.replacingOccurrences(of: ",\"", with: "HACK04")
        lContentString = lContentString.replacingOccurrences(of: ", \"", with: "HACK04")
        lContentString = lContentString.replacingOccurrences(of: ", ", with: ",")
        lContentString = lContentString.replacingOccurrences(of: ",", with: ",\"")
        
        lContentString = lContentString.replacingOccurrences(of: "HACK04", with: ",\"")
        lContentString = lContentString.replacingOccurrences(of: "HACK03", with: ",{")
        lContentString = lContentString.replacingOccurrences(of: "HACK02", with: ":")
        lContentString = lContentString.replacingOccurrences(of: "HACK01", with: "://")
        lContentString = lContentString.replacingOccurrences(of: "\"{", with: "{")
        
        return lContentString
    }
    
    /**
     This method is used to parse YAML string retrieved from the RCCD file
     - Parameter String: The YAML string retieved from the RCCD file downloaded.
     */
    public class func parseYaml(aYamlString: String) -> Yaml {
        var lParsedYamlString: Yaml!
        do{
         lParsedYamlString = try Yaml.load(aYamlString)
        } catch {
            
        }
        return lParsedYamlString
    }
}
