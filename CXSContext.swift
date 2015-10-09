//
//  CXSContext.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 09.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class CXSContext {
    
    var profileId : String?
    var sessionId : String? = "12345"
    var profileSegments : [String]?
    var profileProperties : [String:AnyObject]?
    var sessionProperties : [String:AnyObject]?
    var filteringResults : [String:AnyObject]?
    var trackedConditions : [String]?
    
    init() {
        
    }
    
    init(copy : CXSContext) {
    
    }
    
    init(fromNSDictionary : NSDictionary) {
        profileId = fromNSDictionary["profileId"] as? String
        sessionId = fromNSDictionary["sessionId"] as? String
        // profileSegments todo
        profileProperties = fromNSDictionary["profileProperties"] as? [String:AnyObject]
        sessionProperties = fromNSDictionary["sessionProperties"] as? [String:AnyObject]
    }
}