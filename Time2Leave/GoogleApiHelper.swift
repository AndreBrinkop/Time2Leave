//
//  GoogleAPIHelper.swift
//  Time2Leave
//
//  Created by André Brinkop on 29.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

class GoogleApiHelper {
    
    // MARK: - Properties
    
    struct urlComponents {
        static let scheme = "scheme"
        static let host = "host"
        static let path = "path"
        static let output = "output"
    }
    
    // MARK: - Helper Methods

    public static func buildUrl(method: String = "", requestParameters: [String : Any], urlComponents: [String : String]) -> URL {
        var components = URLComponents()
        components.scheme = urlComponents[self.urlComponents.scheme]
        components.host = urlComponents[self.urlComponents.host]
        
        let path = urlComponents[self.urlComponents.path]! + method + urlComponents[self.urlComponents.output]!
        components.path = path
        
        components.queryItems = [URLQueryItem]()
        for (name, value) in requestParameters {
            components.queryItems?.append(URLQueryItem(name: name, value: "\(value)"))
        }
        print(components.url!)
        return components.url!
    }
}
