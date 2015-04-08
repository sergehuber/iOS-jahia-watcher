//
//  JahiaWatcherSettings.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 07.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class JahiaWatcherSettings {

    class var sharedInstance: JahiaWatcherSettings {
        struct Static {
            static let instance: JahiaWatcherSettings = JahiaWatcherSettings()
        }
        return Static.instance
    }
    
    var jahiaUserName : String = "root"
    var jahiaPassword : String = "root1234"
    var jahiaUserPath : String = "/users/root"
    var jahiaServerHost : String = "localhost"
    var jahiaServerPort : Int = 8080
    var jahiaServerProtocol : String = "http"
    var jahiaServerContextPath : String = ""
    var jahiaServerLoginServletPath : String = "/cms/login"
    var jahiaServerJcrApiServletPath : String = "/modules/api/jcr/v1"
    
    init() {
        load()
    }
    
    func load() {
        let mySharedDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.jahia.mobile.apps.Jahia-Watcher")!

        if (mySharedDefaults.stringForKey("jahiaUserName") != nil) {
            jahiaUserName = mySharedDefaults.stringForKey("jahiaUserName")!
        }
        if (mySharedDefaults.stringForKey("jahiaPassword") != nil) {
            jahiaPassword = mySharedDefaults.stringForKey("jahiaPassword")!
        }
        if (mySharedDefaults.stringForKey("jahiaUserPath") != nil) {
            jahiaUserPath = mySharedDefaults.stringForKey("jahiaUserPath")!
        }
        if (mySharedDefaults.stringForKey("jahiaServerHost") != nil) {
            jahiaServerHost = mySharedDefaults.stringForKey("jahiaServerHost")!
        }
        if (mySharedDefaults.integerForKey("jahiaServerPort") != 0) {
            jahiaServerPort = mySharedDefaults.integerForKey("jahiaServerPort")
        }
        if (mySharedDefaults.stringForKey("jahiaServerProtocol") != nil) {
            jahiaServerProtocol = mySharedDefaults.stringForKey("jahiaServerProtocol")!
        }
        if (mySharedDefaults.stringForKey("jahiaServerContextPath") != nil) {
            jahiaServerContextPath = mySharedDefaults.stringForKey("jahiaServerContextPath")!
        }
        if (mySharedDefaults.stringForKey("jahiaServerLoginServletPath") != nil) {
            jahiaServerLoginServletPath = mySharedDefaults.stringForKey("jahiaServerLoginServletPath")!
        }
        if (mySharedDefaults.stringForKey("jahiaServerJcrApiServletPath") != nil) {
            jahiaServerJcrApiServletPath = mySharedDefaults.stringForKey("jahiaServerJcrApiServletPath")!
        }
        
        mySharedDefaults.synchronize()
        
    }
    
    func save() {
        let mySharedDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.jahia.mobile.apps.Jahia-Watcher")!;
        
        mySharedDefaults.setObject(jahiaUserName, forKey: "jahiaUserName")
        mySharedDefaults.setObject(jahiaPassword, forKey: "jahiaPassword")
        mySharedDefaults.setObject(jahiaUserPath, forKey: "jahiaUserPath")
        mySharedDefaults.setObject(jahiaServerHost, forKey: "jahiaServerHost")
        mySharedDefaults.setInteger(jahiaServerPort, forKey: "jahiaServerPort")
        mySharedDefaults.setObject(jahiaServerProtocol, forKey: "jahiaServerProtocol")
        mySharedDefaults.setObject(jahiaServerContextPath, forKey: "jahiaServerContextPath")
        mySharedDefaults.setObject(jahiaServerLoginServletPath, forKey: "jahiaServerLoginServletPath")
        mySharedDefaults.setObject(jahiaServerJcrApiServletPath, forKey: "jahiaServerJcrApiServletPath")
      
        mySharedDefaults.synchronize()
        
    }
    
    func contextUrl() -> String {
        return "\(jahiaServerProtocol)://\(jahiaServerHost):\(jahiaServerPort)/\(jahiaServerContextPath)"
    }
    
    func loginUrl() -> String {
        return contextUrl() + jahiaServerLoginServletPath;
    }
    
    func jcrApiUrl() -> String {
        return contextUrl() + jahiaServerJcrApiServletPath;
    }
    
}