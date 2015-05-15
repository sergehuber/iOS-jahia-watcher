//
//  TasksRowController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit

class TasksRowController : NSObject {
    
    @IBOutlet weak var taskNameLabel: WKInterfaceLabel!
    @IBOutlet weak var taskAssigneeUserKeyLabel: WKInterfaceLabel!
    @IBOutlet weak var taskDescriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var taskStateLabel: WKInterfaceLabel!
}
