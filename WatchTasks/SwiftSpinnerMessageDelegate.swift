//
//  SwiftSpinnerMessageDelegate.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 14.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class SwiftSpinnerMessageDelegate : MessageDelegate {

    func displayMessage(message : String) {
        //SwiftSpinner.show(message, animated:true)
        println("message:" + message)
    }
    
    func hideAllMessages() {
        //SwiftSpinner.hide()
    }
    
    
}