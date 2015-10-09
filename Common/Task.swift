//
//  Task.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class Task {
    
    var identifier : String?
    var name : String?
    var path : String?
    var title : String?
    var assigneeUserKey : String?
    var description : String?
    var priority : String?
    var dueDate : NSDate?
    var state : String?
    var completed : Bool = false
    var possibleOutcomes : [String]?
    var targetNodeName : String?
    var targetNodePath : String?
    var targetNodeIdentifier : String?
    var previewUrl : String?
    var nextActions : [TaskAction]?

    init(taskName : String, fromNSDictionary : NSDictionary) {
        self.name = taskName
        let task = fromNSDictionary
        let properties = task["properties"] as! NSDictionary
        
        identifier = task["id"] as? String
        path = task["path"] as? String
        
        
        let complexTitle = ServerServices.getStringPropertyValue(properties, propertyName: "jcr__title")
        
        let matches = ServerServices.matchesForRegexInText("##resourceBundle\\((.*),(.*)\\)## : (.*)", text: complexTitle)
        
        title = ServerServices.capitalizeFirstLetter("\(matches[1]) of content \(matches[3])")
        assigneeUserKey = ServerServices.getStringPropertyValue(properties, propertyName: "assigneeUserKey")
        description = ServerServices.getStringPropertyValue(properties, propertyName: "description")
        priority = ServerServices.getStringPropertyValue(properties, propertyName: "priority")
        dueDate = ServerServices.getDatePropertyValue(properties, propertyName: "dueDate")

        state = ServerServices.capitalizeFirstLetter(ServerServices.getStringPropertyValue(properties, propertyName : "state"))
        if let taskState = state {
            if (taskState == "finished") {
                completed = true
            }
        }
        
        possibleOutcomes = ServerServices.getStringArrayPropertyValues(properties, propertyName : "possibleOutcomes")
        
        targetNodeIdentifier = ServerServices.getStringPropertyValue(properties, propertyName: "targetNode")
        if (targetNodeIdentifier != nil) {
            if let targetNode = properties["targetNode"] as? NSDictionary {
                if let targetNodeReferences = targetNode["references"] as? NSDictionary {
                    if let targetNodeReference = targetNodeReferences[targetNodeIdentifier!] as? NSDictionary {
                        targetNodeName = targetNodeReference["name"] as? String
                        targetNodePath = targetNodeReference["path"] as? String
                    }
                 }
            }
        }
    }
    
}
