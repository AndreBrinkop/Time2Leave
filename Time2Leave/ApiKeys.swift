//
//  ApiKeys.swift
//  Time2Leave
//
//  Created by André Brinkop on 25.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

func getAPIKey(_ name: String) -> String {
    guard let plistPath = Bundle.main.path(forResource: Constants.apiKeyPlistName, ofType: "plist") else {
        fatalError("Could not find \"\(Constants.apiKeyPlistName).plist\" file")
    }
    
    let plist = NSDictionary(contentsOfFile:plistPath)
    
    guard let apiKey = plist?.object(forKey: name) as? String else {
        fatalError("Could not find API key named \"\(name)\" in the \"\(Constants.apiKeyPlistName).plist\" file")
    }
    
    return apiKey
}
