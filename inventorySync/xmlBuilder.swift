//
//  File.swift
//  inventorySync
//
//  Created by Doyle, Mark(Information Technology Services) on 4/22/19.
//  Copyright © 2019 Doyle, Mark(Information Technology Services). All rights reserved.
//

import Foundation
import Cocoa

public class xmlBuilder {
    
    var xml: XMLDocument?
    
    public func createPUTURL(url: String, endpoint: String, idType: String, columnA: String) -> URL {
        let stringURL = "\(url)\(endpoint)/\(idType)/\(columnA)"
        let urlwithPercentEscapes = stringURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let encodedURL = NSURL(string: urlwithPercentEscapes!)
        //print(urlwithPercentEscapes!) // Uncomment for debugging
        return encodedURL! as URL
    }
    
    
    // Create the URL that is used to verify the credentials against reading activation code
    public func createGETURL(url: String) -> URL {
        let stringURL = "\(url)activationcode"
        let encodedURL = NSURL(string: stringURL)
        //print(urlwithPercentEscapes!) // Uncomment for debugging
        return encodedURL! as URL
    }
    
    
}
