//
//  MessageProtocol.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 14.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

protocol MessageDelegate {
    func displayMessage(message : String)
    func hideAllMessages()
}