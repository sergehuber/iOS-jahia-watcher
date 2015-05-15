//
//  ConfirmationDialogContext.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 15.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class ConfirmationDialogContext {
    var identifier : String?
    var title : String?
    var message : String?
    var yesHandler : ((context : ConfirmationDialogContext) -> ())?
    var noHandler : ((context : ConfirmationDialogContext) -> ())?
    
    init(identifier : String, title : String, message : String, yesHandler: ((context : ConfirmationDialogContext) -> ())?, noHandler: ((context : ConfirmationDialogContext) -> ())?) {
        self.identifier = identifier
        self.title = title
        self.message = message
        self.yesHandler = yesHandler
        self.noHandler = noHandler
    }
}