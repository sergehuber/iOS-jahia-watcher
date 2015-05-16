//
//  Task.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class Task {
    
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
        
        path = task["path"] as? String
        
        let complexTitle = JahiaServerServices.getStringPropertyValue(properties, propertyName: "jcr__title")
        
        let matches = JahiaServerServices.matchesForRegexInText("##resourceBundle\\((.*),(.*)\\)## : (.*)", text: complexTitle)
        
        title = JahiaServerServices.capitalizeFirstLetter("\(matches[1]) of content \(matches[3])")
        assigneeUserKey = JahiaServerServices.getStringPropertyValue(properties, propertyName: "assigneeUserKey")
        description = JahiaServerServices.getStringPropertyValue(properties, propertyName: "description")
        priority = JahiaServerServices.getStringPropertyValue(properties, propertyName: "priority")
        dueDate = JahiaServerServices.getDatePropertyValue(properties, propertyName: "dueDate")

        state = JahiaServerServices.capitalizeFirstLetter(JahiaServerServices.getStringPropertyValue(properties, propertyName : "state"))
        if let taskState = state {
            if (taskState == "finished") {
                completed = true
            }
        }
        
        possibleOutcomes = JahiaServerServices.getStringArrayPropertyValues(properties, propertyName : "possibleOutcomes")
        
        targetNodeIdentifier = JahiaServerServices.getStringPropertyValue(properties, propertyName: "targetNode")
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
