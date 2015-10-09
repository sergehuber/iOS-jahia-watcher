//
//  Event.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 09.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class CXSEvent {
    
    var eventType : String?
    var sessionId : String?
    var profileId : String?
    var timeStamp : NSDate?
    var properties : [String:AnyObject]?
    var source : CXSItem?
    var target : CXSItem?
    var scope : String?
    
    init() {
        
    }
    
    init(copy : CXSEvent) {
    
    }
    
    init(fromNSDictionary : NSDictionary) {
    
    }
    
    func toDictionary() -> [String:AnyObject] {
        var dictionary = [String:AnyObject]()
        dictionary["eventType"] = eventType!
        dictionary["sessionId"] = sessionId!
        dictionary["profileId"] = profileId!
        if let _ = properties {
            dictionary["properties"] = properties!
        }
        dictionary["source"] = source!.toDictionary()
        dictionary["target"] = target!.toDictionary()
        if let _ = scope {
            dictionary["scope"] = scope!
        }
        
        return dictionary
    }
}