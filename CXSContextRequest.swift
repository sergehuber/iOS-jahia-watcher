//
//  CXSContextRequest.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 14.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class CXSContextRequest {
    var source : CXSItem?
    var requireSegments : Bool?
    var requiredProfileProperties : [String]?
    var requiredSessionProperties : [String]?
    var events : [CXSEvent]?
    
    func toDictionary() -> [String:AnyObject] {
        var dictionary = [String:AnyObject]()
        if let _ = source {
            dictionary["source"] = source!.toDictionary()
        }
        if let _ = requireSegments {
            dictionary["requireSegments"] = requireSegments!.description
        }
        if let _ = requiredProfileProperties {
            dictionary["requiredProfileProperties"] = requiredProfileProperties!
        }
        if let _ = requiredSessionProperties {
            dictionary["requiredSessionProperties"] = requiredSessionProperties!
        }
        return dictionary
    }

}