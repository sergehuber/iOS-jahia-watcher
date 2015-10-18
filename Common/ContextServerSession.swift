//
//  ContextServerSession.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class ContextServerSession {
    let contextServerSettings : ContextServerSettings = ContextServerSettings.sharedInstance
    let serverServices : ServerServices = ServerServices.sharedInstance
    
    var online : Bool = false
    var servicesAvailable : Bool = false
    var loggedIn : Bool = false
    var lastConnectionAttemptTime : NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
    var attemptedLogin : Bool = false
    var contextRequested : Bool = false
    var currentContext : CXSContext? = CXSContext()
    
    init() {
    }

    func areServicesAvailable() -> Bool {
        if (!contextRequested) {
            currentContext = getContext()
            contextRequested = true
            if (currentContext == nil) {
                serverServices.mprintln("Couldn't get context, marking services as unavailable")
                servicesAvailable = false
                return servicesAvailable
            } else {
                if (!servicesAvailable) {
                    return servicesAvailable
                }
            }
        } else {
        }
        if (!servicesAvailable) {
            serverServices.mprintln("Services not available")
            return false
        }
        return true;
    }
    
    func getContext() -> CXSContext? {
        var result : Bool = false
        serverServices.mprintln("Retrieving context from Context Server...")
        var context : CXSContext? = nil
        
        var cxsContextRequest = CXSContextRequest()
        cxsContextRequest.source = CXSItem(itemType: "mobileApp", itemId: "JahiaWatcherMobileApp", scope: "ACMESPACE")
        cxsContextRequest.requireSegments = true
        cxsContextRequest.requiredProfileProperties = ["*"]
        cxsContextRequest.requiredSessionProperties = ["*"]
        let cxsContextRequestData = try! NSJSONSerialization.dataWithJSONObject(cxsContextRequest.toDictionary(), options: NSJSONWritingOptions.PrettyPrinted)
        let cxsContextRequestJSON = String(data: cxsContextRequestData, encoding: NSUTF8StringEncoding)

        let (dataVal,online) = serverServices.httpRequest(contextServerSettings.retrieveContextUrl() + "?sessionId=\(contextServerSettings.contextServerSessionId!)", body: cxsContextRequestJSON, contentType: "application/json", fileName: "context.txt", httpMethod: "POST", timeoutInterval: 2)
        
        if (!online) {
            servicesAvailable = false
            loggedIn = false
        } else {
        
            if let data = dataVal {
                serverServices.mprintln("Context retrieval successful.")
                // var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                servicesAvailable = true
                loggedIn = true
                result = true
                context = CXSContext(fromNSDictionary:jsonResult)
            } else {
                serverServices.mprintln("Context retrieval failed")
                loggedIn = false
            }
        }
        serverServices.hideMessages()
        return context
    }
    
    func registerDeviceToken(deviceToken : String) {
        if (!areServicesAvailable()) {
            return
        }
        serverServices.mprintln("Registering device token into Context Server...")
        let escapedDeviceToken : String = deviceToken.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let (dataVal,online) = serverServices.httpGet(contextServerSettings.registerDeviceTokenUrl() + "?deviceToken=\(escapedDeviceToken)", fileName: "registerDeviceToken.txt")
        
        if let result = dataVal {
            serverServices.mprintln("Device token \(deviceToken) successfully registered on Context Server for the current user")
        } else {
            serverServices.mprintln("Device registration failed")
        }
        serverServices.hideMessages()
    }
    
    func sendEvents(events : CXSEventCollectorRequest) {
        if (!areServicesAvailable()) {
            return
        }
        let data = try! NSJSONSerialization.dataWithJSONObject(events.toDictionary(), options: NSJSONWritingOptions.PrettyPrinted)
        let dataString = String(data: data, encoding: NSUTF8StringEncoding)
        serverServices.httpRequest(contextServerSettings.eventCollectorUrl() + "?sessionId=\(contextServerSettings.contextServerSessionId!)", body: dataString, fileName: "events.txt", contentType: "application/json", expectedSuccessCode: 200, httpMethod: "POST")
    }
    
    func removeProperty(profileId : String, propertyName : String) {
        serverServices.httpRequest(contextServerSettings.privacyServiceUrl() + "/profiles/\(profileId)/properties/\(propertyName)", body: nil, fileName: "removeProperty.txt", contentType: "application/json", expectedSuccessCode: 200, httpMethod: "DELETE")
    }

    func deleteProfile(profileId : String) {
        serverServices.httpRequest(contextServerSettings.privacyServiceUrl() + "/profiles/\(profileId)", body: nil, fileName: "deleteProfile.txt", contentType: "application/json", expectedSuccessCode: 200, httpMethod: "DELETE")
    }

    func anonymizeProfile(profileId : String) {
        serverServices.httpRequest(contextServerSettings.privacyServiceUrl() + "/profiles/\(profileId)/anonymize", body: nil, fileName: "anonymizeProfile.txt", contentType: "application/json", expectedSuccessCode: 200, httpMethod: "POST")
    }
    
}
