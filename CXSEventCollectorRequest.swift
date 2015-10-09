//
//  CXSEventCollectorRequest.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 09.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class CXSEventCollectorRequest {
    var events : [CXSEvent] = []
    
    func toDictionary() -> [String:AnyObject] {
        var dictionary = [String:AnyObject]()
        var dictionaryEventArray = [[String:AnyObject]]()
        for event in events {
            dictionaryEventArray.append(event.toDictionary())
        }
        dictionary["events"] = dictionaryEventArray
        return dictionary
    }
}