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
    var loggedIn : Bool = false
    var attemptedLogin : Bool = false
    static var messageDelegate : MessageDelegate?
    
    class var sharedInstance: JahiaServerServices {
        struct Static {
            static let instance: JahiaServerServices = JahiaServerServices()
        }
        return Static.instance
    }
    
    class func mprintln(message : String) {
        messageDelegate?.displayMessage(message)
    }
    
    class func hideMessages() {
        messageDelegate?.hideAllMessages()
    }
    
    func mprintln(message : String) {
        JahiaServerServices.mprintln(message)
    }
    
    func hideMessages() {
        JahiaServerServices.hideMessages()
    }
    
    func login() {
        
        mprintln("Logging into Jahia...")
        
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
        request.timeoutInterval = 4
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode == 200) {
                mprintln("Login successful.")
                servicesAvailable = true
                loggedIn = true
                let userPath = getUserPath()
                if let realUserPath = userPath {
                    jahiaWatcherSettings.jahiaUserPath = realUserPath
                }
            } else {
                mprintln("Error during login!")
            }
        } else {
            mprintln("Login failed")
            loggedIn = false
        }
        hideMessages()
    }
    
    func areServicesAvailable() -> Bool {
        if (!loggedIn && !attemptedLogin) {
            attemptedLogin = true
            login()
        }
        if (!servicesAvailable) {
            mprintln("Services not available")
            return false
        }
        return true;
    }
    
    func registerDeviceToken(deviceToken : String) {
        if (!areServicesAvailable()) {
            return
        }
        mprintln("Registering device token...")
        let escapedDeviceToken : String = deviceToken.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let jahiaRegisterDeviceTokenURL : NSURL = NSURL(string: jahiaWatcherSettings.registerDeviceTokenUrl() + "?deviceToken=\(escapedDeviceToken)")!
        
        let request = NSMutableURLRequest(URL: jahiaRegisterDeviceTokenURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 4
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error registering device token for current user ?")
            } else {
            }
        } else {
            mprintln("Device registration failed")
        }
        hideMessages()
    }

    func blockUser(userName : String) {
        if (!areServicesAvailable()) {
            return
        }
        mprintln("Blocking user...")
        
        let jahiaBlockUserURL : NSURL = NSURL(string: jahiaWatcherSettings.blockUserUrl() + "?userName=\(userName)")!
        
        let request = NSMutableURLRequest(URL: jahiaBlockUserURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 4
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error blocking user \(userName)?")
            } else {
                mprintln("User \(userName) blocked successfully.")
            }
        } else {
            mprintln("Blocking of user \(userName) failed")
        }
        hideMessages()
    }

    func markAsSpam(nodeIdentifier : String) {
        if (!areServicesAvailable()) {
            return
        }
        mprintln("Marking/unmarking post as spam")
        
        let jahiaMarkAsSpamURL : NSURL = NSURL(string: jahiaWatcherSettings.markAsSpamUrl() + "?nodeIdentifier=\(nodeIdentifier)")!
        
        let request = NSMutableURLRequest(URL: jahiaMarkAsSpamURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 4
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error marking/unmarking post as spam ?")
            } else {
                mprintln("Post marked/unmarked as spam successfully.")
            }
        } else {
            mprintln("Marking/unmarking post as spam failed")
        }
        hideMessages()
    }

    
    func getUserPath() -> String? {
        if (!areServicesAvailable()) {
            return ""
        }
        mprintln("Retrieving current user path...")
        let jahiaUserPathURL : NSURL = NSURL(string: jahiaWatcherSettings.userPathUrl())!
        
        let request = NSMutableURLRequest(URL: jahiaUserPathURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)!
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error retrieving current user path")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                hideMessages()
                return JahiaServerServices.condenseWhitespace(datastring! as String)
            }
        } else {
            mprintln("Coudln't retrieve current user path")
        }
        hideMessages()
        return nil;
    }
    
    func getWorkflowTasks() -> NSDictionary {
        if (!areServicesAvailable()) {
            return NSDictionary()
        }
        
        mprintln("Retrieving workflow tasks...")
        
        let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaWatcherSettings.jcrApiUrl() + "/default/en/paths\(jahiaWatcherSettings.jahiaUserPath)/workflowTasks?includeFullChildren&resolveReferences")!
        
        let request = NSMutableURLRequest(URL: jahiaWorkflowTasksURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error retrieving workflow tasks, probably none were ever created ?")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                hideMessages()
                return jsonResult
                
            }
        } else {
            mprintln("Couldn't retrieve workflow tasks")
        }
        hideMessages()
        return NSDictionary()
    }
    
    func refreshTask(task : Task) -> Task? {
        if (!areServicesAvailable()) {
            return task
        }
        
        mprintln("Refreshing task \(task.path) ...")

        let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaWatcherSettings.jcrApiUrl() + "/default/en/paths\(task.path!)?includeFullChildren&resolveReferences")!
        
        let request = NSMutableURLRequest(URL: jahiaWorkflowTasksURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error retrieving updated task!")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                hideMessages()
                return Task(taskName: task.name!, fromNSDictionary: jsonResult)
                
            }
        } else {
            mprintln("Couldn't retrieve task")
        }
        hideMessages()
        return nil
    }
    
    func getTaskActions(task : Task) -> Task {
        if (!areServicesAvailable()) {
            return task
        }
        mprintln("Retrieving task actions...")

        let jahiaTaskActionsURL : NSURL = NSURL(string: jahiaWatcherSettings.taskActionsUrl(task.path!))!
        
        let request = NSMutableURLRequest(URL: jahiaTaskActionsURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error retrieving task actions!")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                if let previewUrl = jsonResult["preview-url"] as? String {
                    task.previewUrl = previewUrl
                }
                if let possibleActions = jsonResult["possibleActions"] as? [NSDictionary] {
                    var nextActions = [TaskAction]()
                    for possibleAction in possibleActions {
                        let taskAction = TaskAction()
                        taskAction.displayName = possibleAction["displayName"] as? String
                        taskAction.name = possibleAction["name"] as? String
                        taskAction.finalOutcome = possibleAction["finalOutcome"] as? String
                        nextActions.append(taskAction)
                    }
                    task.nextActions = nextActions
                }
            }
        } else {
            mprintln("Couldn't retrieve task actions")
        }
        
        hideMessages()
        return task
    }
    
    func performTaskAction(task: Task, actionName : String, finalOutcome : String?) {
        mprintln("Sending task action \(actionName) with outcome \(finalOutcome) to Jahia server...")
        
        let jahiaTaskActionsURL : NSURL = NSURL(string: jahiaWatcherSettings.taskActionsUrl(task.path!))!
        let request = NSMutableURLRequest(URL: jahiaTaskActionsURL)
        let requestString : String = "action=\(actionName)" + ((finalOutcome != nil) ? "&finalOutcome=\(finalOutcome!)" : "");
        let postData = NSMutableData()
        postData.appendData(requestString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPMethod = "POST"
        request.setValue(NSString(format: "%lu", postData.length) as String, forHTTPHeaderField: "Content-Length")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        request.timeoutInterval = 4
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode == 200) {
                mprintln("Action sent successfully.")
            }
        } else {
            mprintln("Action sending failed")
        }
        hideMessages()
        
    }
    
    func getLatestPosts() -> NSArray {
        if (!areServicesAvailable()) {
            return NSArray()
        }
        mprintln("Retrieving latest posts...")
        
        let jahiaLatestPostsURL : NSURL = NSURL(string: jahiaWatcherSettings.jcrApiUrl() + "/live/en/query")!
        
        let request = NSMutableURLRequest(URL: jahiaLatestPostsURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
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
            if (httpResponse.statusCode != 200) {
                mprintln("Error retrieving latest posts!")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSArray
                
                hideMessages()
                return jsonResult
                
            }
        } else {
            mprintln("Couldn't retrieve latest posts!")
        }
        hideMessages()
        return NSArray()
        
    }
    
    func refreshPost(post : Post) -> Post? {
        if (!areServicesAvailable()) {
            return post
        }
        mprintln("Refreshing post \(post.path!) ...")
        
        let jahiaGetPostURL : NSURL = NSURL(string: jahiaWatcherSettings.jcrApiUrl() + "/live/en/paths\(post.path!)?includeFullChildren&resolveReferences")!
        
        let request = NSMutableURLRequest(URL: jahiaGetPostURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error retrieving post \(post.path)")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                hideMessages()
                return Post(fromNSDictionary: jsonResult)
                
            }
        } else {
            mprintln("Couldn't retrieve update for post \(post.path)")
        }
        hideMessages()
        return nil
        
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
    
    class func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        let re = NSRegularExpression(pattern: regex, options: nil, error: nil)!
        let matches = re.matchesInString(text, options: nil, range: NSMakeRange(0, count(text)))
        
        var result = [String]()
        
        for match in matches as! [NSTextCheckingResult] {
            // range at index 0: full match
            // range at index 1: first capture group
            for groupNumber : Int in 0...match.numberOfRanges-1 {
                let substring = (text as NSString).substringWithRange(match.rangeAtIndex(groupNumber))
                result.append(substring)
            }
        }
        return result
    }
    
    class func capitalizeFirstLetter(input : String?) -> String? {
        var result = input
        if let realInput = input {
            result!.replaceRange(result!.startIndex...result!.startIndex, with: String(result![result!.startIndex]).capitalizedString)
        }
        return result
    }
    
    class func condenseWhitespace(string: String) -> String {
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
        return join(" ", components)
    }
    
}