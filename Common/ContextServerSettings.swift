//
//  ContextServerSettings.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class ContextServerSettings {
    
    class var sharedInstance: ContextServerSettings {
        struct Static {
            static let instance: ContextServerSettings = ContextServerSettings()
        }
        return Static.instance
    }
    
    var contextServerTimeout = 10
    var contextServerHost : String = "localhost"
    var contextServerPort : Int = 9443
    var contextServerProtocol : String = "https"
    var contextServerContextPath : String = ""
    var contextServerRetrieveContextURL = "/context.json"
    var contextServerEventCollectorURL = "/eventcollector"
    
    init() {
        load()
    }
    
    func load() {
        let mySharedDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.jahia.mobile.apps.Jahia-Watcher")!
        
        if (mySharedDefaults.stringForKey("contextServerHost") != nil) {
            contextServerHost = mySharedDefaults.stringForKey("contextServerHost")!
        }
        if (mySharedDefaults.integerForKey("contextServerPort") != 0) {
            contextServerPort = mySharedDefaults.integerForKey("contextServerPort")
        }
        if (mySharedDefaults.stringForKey("contextServerProtocol") != nil) {
            contextServerProtocol = mySharedDefaults.stringForKey("contextServerProtocol")!
        }
        if (mySharedDefaults.stringForKey("contextServerContextPath") != nil) {
            contextServerContextPath = mySharedDefaults.stringForKey("contextServerContextPath")!
        }
        
        mySharedDefaults.synchronize()
        
    }
    
    func save() {
        let mySharedDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.jahia.mobile.apps.Jahia-Watcher")!;
        
        mySharedDefaults.setObject(contextServerHost, forKey: "contextServerHost")
        mySharedDefaults.setInteger(contextServerPort, forKey: "contextServerPort")
        mySharedDefaults.setObject(contextServerProtocol, forKey: "contextServerProtocol")
        mySharedDefaults.setObject(contextServerContextPath, forKey: "contextServerContextPath")
        
        mySharedDefaults.synchronize()
        
    }
    
    func resetDefaults() {
        let mySharedDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.jahia.mobile.apps.Jahia-Watcher")!
        mySharedDefaults.removeObjectForKey("contextServerHost")
        mySharedDefaults.removeObjectForKey("contextServerPort")
        mySharedDefaults.removeObjectForKey("contextServerProtocol")
        mySharedDefaults.removeObjectForKey("contextServerContextPath")
    }
    
    func contextUrl() -> String {
        let url = "\(contextServerProtocol)://\(contextServerHost):\(contextServerPort)"
        if (contextServerContextPath == "") {
            return url;
        } else {
            return url + "/\(contextServerContextPath)";
        }
    }
    
    func registerDeviceTokenUrl() -> String {
        return contextUrl() + "/cxs/registerDeviceToken"
    }
    
    func contentRenderUrl(contentPath : String) -> String {
        return contextUrl() + contentPath
    }
    
    func retrieveContextUrl() -> String {
        return contextUrl() + contextServerRetrieveContextURL
    }
    
    func eventCollectorUrl() -> String {
        return contextUrl() + contextServerEventCollectorURL
    }
    
}