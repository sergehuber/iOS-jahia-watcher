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
    var servicesAvailable : Bool = false
    
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
        request.setValue(NSString(format: "%lu", postData.length) as String, forHTTPHeaderField: "Content-Length")
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
            servicesAvailable = true
        } else {
            println("Login failed")
        }
    }
    
    func areServicesAvailable() -> Bool {
        if (!servicesAvailable) {
            println("Services not available")
            return false
        }
        return true;
    }
    
    func registerDeviceToken(deviceToken : String) {
        if (!areServicesAvailable()) {
            return
        }
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

    func blockUser(userName : String) {
        if (!areServicesAvailable()) {
            return
        }
        println("Blocking user...")
        
        let jahiaBlockUserURL : NSURL = NSURL(string: jahiaWatcherSettings.blockUserUrl() + "?userName=\(userName)")!
        
        let request = NSMutableURLRequest(URL: jahiaBlockUserURL)
        
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

    func markAsSpam(nodeIdentifier : String) {
        if (!areServicesAvailable()) {
            return
        }
        println("Marking post as spam")
        
        let jahiaMarkAsSpamURL : NSURL = NSURL(string: jahiaWatcherSettings.markAsSpamUrl() + "?nodeIdentifier=\(nodeIdentifier)")!
        
        let request = NSMutableURLRequest(URL: jahiaMarkAsSpamURL)
        
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
        if (!areServicesAvailable()) {
            return ""
        }
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
                return datastring! as String;
            }
        } else {
            println("Coudln't retrieve current user path")
        }
        return "";
    }
    
    func getWorkflowTasks() -> NSDictionary {
        if (!areServicesAvailable()) {
            return NSDictionary()
        }
        
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
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                return jsonResult
                
            }
        } else {
            println("Couldn't retrieve workflow tasks")
        }
        return NSDictionary()
    }
    
    func getLatestPosts() -> NSArray {
        if (!areServicesAvailable()) {
            return NSArray()
        }
        println("Retrieving latest posts...")
        
        let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaWatcherSettings.jcrApiUrl() + "/live/en/query")!
        
        let request = NSMutableURLRequest(URL: jahiaWorkflowTasksURL)
        let requestString : String = "{\"query\" : \"select * from [jnt:post] as p order by p.[jcr:created] desc\", \"limit\": 20, \"offset\":0 }";
        let postData = NSMutableData()
        postData.appendData(requestString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPMethod = "POST"
        request.setValue(NSString(format: "%lu", postData.length) as String, forHTTPHeaderField: "Content-Length")
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
                var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSArray
                
                return jsonResult
                
            }
        } else {
            println("Couldn't retrieve latest posts")
        }
        return NSArray()
        
    }
    
    class func stripHTML(input : String) -> String {
        var output = input.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        output = output.stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
        output = output.stringByReplacingOccurrencesOfString("&quote;", withString: "'")
        output = output.stringByReplacingOccurrencesOfString("&rsquo;", withString: "'")
        output = output.stringByReplacingOccurrencesOfString("&#39;", withString: "'")
        output = output.stringByReplacingOccurrencesOfString("&amp;", withString: "&")
        return output
    }
    
    class func getShortDate(date : NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
        
        let dateString = formatter.stringFromDate(date)
        return dateString
    }
    
    class func getRelativeTime(date : NSDate) -> String {
        return date.relativeTime;
    }
    
    class func getStringPropertyValue(properties : NSDictionary, propertyName : String) -> String? {
        let property = properties[propertyName] as? NSDictionary
        if let realProperty = property {
            return realProperty["value"] as? String
        } else {
            return nil;
        }
    }

    class func getDatePropertyValue(properties : NSDictionary, propertyName : String) -> NSDate? {
        let property = properties[propertyName] as? NSDictionary
        if let realProperty = property {
            return realProperty["value"] as? NSDate
        } else {
            return nil;
        }
    }

    class func getStringArrayPropertyValues(properties : NSDictionary, propertyName : String) -> [String]? {
        let property = properties[propertyName] as? NSDictionary
        if let realProperty = property {
            return realProperty["value"] as? [String]
        } else {
            return nil;
        }
    }
    
}