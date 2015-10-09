//
//  JahiaServerSettings.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 07.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class JahiaServerSettings {

    class var sharedInstance: JahiaServerSettings {
        struct Static {
            static let instance: JahiaServerSettings = JahiaServerSettings()
        }
        return Static.instance
    }
    
    var jahiaServerTimeout = 10
    var jahiaUsePreparedQueries = true
    var jahiaUserName : String = "root"
    var jahiaPassword : String = "root1234"
    var jahiaUserPath : String = "/users/root"
    var jahiaServerHost : String = "localhost"
    var jahiaServerPort : Int = 8080
    var jahiaServerProtocol : String = "http"
    var jahiaServerContextPath : String = ""
    var jahiaServerLoginServletPath : String = "/cms/login"
    var jahiaServerJcrApiServletPath : String = "/modules/api/jcr/v1"
    var jahiaServerUserPathServletPath : String = "/cms/render/live/en/sites.userPath.do"
    var jahiaServerRegisterDeviceTokenServletPath : String = "/cms/render/live/en/sites.registerToken.do"
    var jahiaServerBlockUserServletPath : String = "/cms/render/live/en/sites.blockUser.do"
    var jahiaServerUnblockUserServletPath : String = "/cms/render/live/en/sites.unblockUser.do"
    var jahiaServerMarkAsSpamServletPath : String = "/cms/render/live/en/sites.markAsSpam.do"
    var jahiaServerUnmarkAsSpamServletPath : String = "/cms/render/live/en/sites.unmarkAsSpam.do"
    var jahiaServerTaskActionsPartialPath : String = "/cms/render/default/en";
    var jahiaServerPostActionsPartialPath : String = "/cms/render/live/en";
    
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
      
        mySharedDefaults.synchronize()
        
    }
    
    func resetDefaults() {
        let mySharedDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.jahia.mobile.apps.Jahia-Watcher")!
        mySharedDefaults.removeObjectForKey("jahiaUserName")
        mySharedDefaults.removeObjectForKey("jahiaPassword")
        mySharedDefaults.removeObjectForKey("jahiaUserPath")
        mySharedDefaults.removeObjectForKey("jahiaServerHost")
        mySharedDefaults.removeObjectForKey("jahiaServerPort")
        mySharedDefaults.removeObjectForKey("jahiaServerProtocol")
        mySharedDefaults.removeObjectForKey("jahiaServerContextPath")
    }
    
    func contextUrl() -> String {
        let url = "\(jahiaServerProtocol)://\(jahiaServerHost):\(jahiaServerPort)"
        if (jahiaServerContextPath == "") {
            return url;
        } else {
            return url + "/\(jahiaServerContextPath)";
        }
    }
    
    func loginUrl() -> String {
        return contextUrl() + jahiaServerLoginServletPath;
    }
    
    func jcrApiUrl() -> String {
        return contextUrl() + jahiaServerJcrApiServletPath;
    }
    
    func userPathUrl() -> String {
        return contextUrl() + jahiaServerUserPathServletPath;
    }
    
    func registerDeviceTokenUrl() -> String {
        return contextUrl() + jahiaServerRegisterDeviceTokenServletPath;
    }
    
    func blockUserUrl() -> String {
        return contextUrl() + jahiaServerBlockUserServletPath;
    }

    func unblockUserUrl() -> String {
        return contextUrl() + jahiaServerUnblockUserServletPath;
    }
    
    func markAsSpamUrl() -> String {
        return contextUrl() + jahiaServerMarkAsSpamServletPath
    }

    func unmarkAsSpamUrl() -> String {
        return contextUrl() + jahiaServerUnmarkAsSpamServletPath
    }
    
    func contentRenderUrl(contentPath : String) -> String {
        return contextUrl() + contentPath
    }

    func taskActionsUrl(taskPath : String) -> String {
        return contextUrl() + jahiaServerTaskActionsPartialPath + taskPath + ".taskActions.do"
    }

    func postActionsUrl(postPath : String) -> String {
        return contextUrl() + jahiaServerPostActionsPartialPath + postPath + ".postActions.do"
    }
    
}