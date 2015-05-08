//
//  Task.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class Task {
    
    var title : String?
    var assigneeUserKey : String?
    var description : String?
    var priority : String?
    var dueDate : NSDate?
    var state : String?
    var completed : Bool = false
    var possibleOutcomes : [String]?

    init(taskName : String, fromNSDictionary : NSDictionary) {
        self.title = taskName
        let task = fromNSDictionary
        let properties = task["properties"] as! NSDictionary
        
        title = JahiaServerServices.getStringPropertyValue(properties, propertyName: "jcr__title")
        assigneeUserKey = JahiaServerServices.getStringPropertyValue(properties, propertyName: "assigneeUserKey")
        description = JahiaServerServices.getStringPropertyValue(properties, propertyName: "description")
        priority = JahiaServerServices.getStringPropertyValue(properties, propertyName: "priority")
        dueDate = JahiaServerServices.getDatePropertyValue(properties, propertyName: "dueDate")

        state = JahiaServerServices.getStringPropertyValue(properties, propertyName : "state")
        if let taskState = state {
            if (taskState == "finished") {
                completed = true
            }
        }
        
        possibleOutcomes = JahiaServerServices.getStringArrayPropertyValues(properties, propertyName : "possibleOutcomes")
    }
    
}
