//
//  ConfirmationDialogInterfaceController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 15.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit

class ConfirmationDialogInterfaceController: WKInterfaceController {

    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    var yesHandler : ((context : ConfirmationDialogContext) -> ())?
    var noHandler : ((context : ConfirmationDialogContext) -> ())?
    var confirmationDialogContext : ConfirmationDialogContext?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let confirmationDialogContext = context as! ConfirmationDialogContext
        titleLabel.setText(confirmationDialogContext.title)
        messageLabel.setText(confirmationDialogContext.message)
        yesHandler = confirmationDialogContext.yesHandler
        noHandler = confirmationDialogContext.noHandler
        self.confirmationDialogContext = confirmationDialogContext
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func yesButtonPressed() {
        if let realYesHandler = yesHandler {
            realYesHandler(context: confirmationDialogContext!)
        }
        dismissController()
    }
    
    @IBAction func noButtonPressed() {
        if let realNoHandler = noHandler {
            realNoHandler(context: confirmationDialogContext!)
        }
        dismissController()
    }
}
