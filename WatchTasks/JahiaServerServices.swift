//
//  JahiaServerServices.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class JahiaServerServices {

    let jahiaWatcherSettings : JahiaWatcherSettings = JahiaWatcherSettings.sharedInstance
    
    class var sharedInstance: JahiaServerServices {
        struct Static {
            static let instance: JahiaServerServices = JahiaServerServices()
        }
        return Static.instance
    }
    
    func login() {
        
        println("Logging into Jahia...")
        
        let jahiaLoginURL : NSURL = NSURL(string: jahiaWatcherSettings.loginUrl())!
        let request = NSMutableURLRequest(URL: jahiaLoginURL)
        let requestString : String = "doLogin=true&restMode=true&username=\(jahiaWatcherSettings.jahiaUserName)&password=\(jahiaWatcherSettings.jahiaPassword)&redirectActive=false";
        let postData = NSMutableData()
        postData.appendData(requestString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPMethod = "POST"
        request.setValue(NSString(format: "%lu", postData.length), forHTTPHeaderField: "Content-Length")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        request.timeoutInterval = 10
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            println(httpResponse.statusCode)
        } else {
            println("Login failed")
        }
    }
    
    func registerDeviceToken(deviceToken : String) {
        println("Registering device token...")
        let escapedDeviceToken : String = deviceToken.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let jahiaRegisterDeviceTokenURL : NSURL = NSURL(string: jahiaWatcherSettings.registerDeviceTokenUrl() + "?deviceToken=\(escapedDeviceToken)")!
        
        let request = NSMutableURLRequest(URL: jahiaRegisterDeviceTokenURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            println(httpResponse.statusCode)
            if (httpResponse.statusCode != 200) {
                println("Error registering device token for current user ?")
            } else {
            }
        } else {
            println("Device registration failed")
        }
    }
    
    func getUserPath() -> String {
        println("Retrieving current user path...")
        let jahiaUserPathURL : NSURL = NSURL(string: jahiaWatcherSettings.userPathUrl())!
        
        let request = NSMutableURLRequest(URL: jahiaUserPathURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)!
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            println(httpResponse.statusCode)
            if (httpResponse.statusCode != 200) {
                println("Error retrieving workflow tasks, probably none were ever created ?")
            } else {
                var datastring = NSString(data: dataVal, encoding: NSUTF8StringEncoding)
                return datastring!;
            }
        } else {
            println("Coudln't retrieve current user path")
        }
        return "";
    }
    
    func getWorkflowTasks() -> NSDictionary {
        
        println("Retrieving workflow tasks...")
        
        let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaWatcherSettings.jcrApiUrl() + "/default/en/paths\(jahiaWatcherSettings.jahiaUserPath)/workflowTasks?noLinks&includeFullChildren")!
        
        let request = NSMutableURLRequest(URL: jahiaWorkflowTasksURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            println(httpResponse.statusCode)
            if (httpResponse.statusCode != 200) {
                println("Error retrieving workflow tasks, probably none were ever created ?")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                
                return jsonResult
                
            }
        } else {
            println("Couldn't retrieve workflow tasks")
        }
        return NSDictionary()
    }
    
    func getLatestPosts() -> NSArray {
        println("Retrieving latest posts...")
        
        let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaWatcherSettings.jcrApiUrl() + "/live/en/query")!
        
        let request = NSMutableURLRequest(URL: jahiaWorkflowTasksURL)
        let requestString : String = "{\"query\" : \"select * from [jnt:post] as p order by p.[jcr:created] desc\", \"limit\": 10, \"offset\":0 }";
        let postData = NSMutableData()
        postData.appendData(requestString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPMethod = "POST"
        request.setValue(NSString(format: "%lu", postData.length), forHTTPHeaderField: "Content-Length")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        request.timeoutInterval = 10
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            println(httpResponse.statusCode)
            if (httpResponse.statusCode != 200) {
                println("Error retrieving workflow tasks, probably none were ever created ?")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSArray
                
                return jsonResult
                
            }
        } else {
            println("Couldn't retrieve latest posts")
        }
        return NSArray()
        
    }
    
}