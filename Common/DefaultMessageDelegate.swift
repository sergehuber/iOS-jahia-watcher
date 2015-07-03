//
//  DefaultMessageDelegate.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 16.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class DefaultMessageDelegate: MessageDelegate {
    func displayMessage(message : String) {
        println(message)
    }
    
    func hideAllMessages() {
    }

}