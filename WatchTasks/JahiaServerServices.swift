//
//  JahiaServerServices.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class JahiaServerServices {

    let jahiaServerSettings : JahiaServerSettings = JahiaServerSettings.sharedInstance
    var servicesAvailable : Bool = false
    var loggedIn : Bool = false
    var lastConnectionAttemptTime : NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
    var attemptedLogin : Bool = false
    var jcrApiVersionMap : [String:AnyObject]? = nil
    var jcrApiVersion : String? = nil
    var jcrApiModuleVersion : String? = nil
    var jcrApiVersionRequested = false
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
    
    func getUserName() -> String {
        return jahiaServerSettings.jahiaUserName
    }
    
    func writeDataToFile(filePath : String?, data : NSData) -> Bool {
        if (filePath == nil) {
            return false
        }
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as! [String]
        let documentDirectory = paths[0]
        let fullFilePath = documentDirectory.stringByAppendingPathComponent(filePath!)
        data.writeToFile(fullFilePath, atomically: true)
        return true
    }
    
    func readDataFromFile(filePath : String?) -> NSData? {
        if (filePath == nil) {
            return nil
        }
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as! [String]
        let documentDirectory = paths[0]
        let fullFilePath = documentDirectory.stringByAppendingPathComponent(filePath!)
        let data = NSData(contentsOfFile: fullFilePath)
        return data
    }
    
    func readJSONFromFile(filePath : String?) -> AnyObject? {
        if (filePath == nil) {
            return nil
        }
        let data = readDataFromFile(filePath)
        if let dataVal = data {
            var error : NSError?
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
            return jsonResult
        }
        return nil
    }
    
    func httpGet(url : String, fileName : String? = nil, expectedSuccessCode : Int = 200, timeoutInterval : NSTimeInterval = 10, completionHandler: ((NSData?, online: Bool) -> Void)? = nil) -> NSData? {
        let getURL : NSURL = NSURL(string: url)!
        
        let request = NSMutableURLRequest(URL: getURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeoutInterval
        
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                executeHttpGet(request, fileName: fileName, expectedSuccessCode: expectedSuccessCode, completionHandler: completionHandler)
            }
            
            // we immediately return an existing file content if there is one
            let dataVal = readDataFromFile(fileName)
            if (dataVal != nil) {
                mprintln("Loaded data from local file \(fileName) successfully.")
            }
            return dataVal
            
        } else {
        
            return executeHttpGet(request, fileName: fileName, expectedSuccessCode: expectedSuccessCode, completionHandler: completionHandler)
        }
    }
    
    func executeHttpGet(request : NSMutableURLRequest, fileName : String? = nil, expectedSuccessCode : Int = 200, completionHandler: ((NSData?, online: Bool) -> Void)? = nil) -> NSData? {
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode == expectedSuccessCode) {
                servicesAvailable = true
                writeDataToFile(fileName, data: dataVal!)
                if (completionHandler != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler!(dataVal, online: true)
                    }
                }
                return dataVal
            } else {
                dataVal = readDataFromFile(fileName)
                if (completionHandler != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler!(dataVal, online: false)
                    }
                }
                return dataVal
            }
        } else {
            mprintln("Couldn't retrieve data from url \(request.URL)")
            dataVal = readDataFromFile(fileName)
            if (completionHandler != nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler!(dataVal, online: false)
                }
            }
            return dataVal
        }
    }
    
    func httpPost(url : String, body : String, fileName : String? = nil, contentType : String? = nil, expectedSuccessCode : Int = 200, timeoutInterval : NSTimeInterval = 10, completionHandler: ((NSData?, online: Bool) -> Void)? = nil) -> NSData? {
        let postURL : NSURL = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: postURL)
        let postData = NSMutableData()
        postData.appendData(body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.setValue(NSString(format: "%lu", postData.length) as String, forHTTPHeaderField: "Content-Length")
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        if (contentType != nil) {
            request.addValue(contentType!, forHTTPHeaderField: "Content-Type")
        } else {
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        request.HTTPBody = postData
        request.timeoutInterval = timeoutInterval

        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                executeHttpPost(request, fileName: fileName, expectedSuccessCode: expectedSuccessCode, completionHandler: completionHandler)
            }
            
            // we immediately return an existing file content if there is one
            let dataVal = readDataFromFile(fileName)
            if (dataVal != nil) {
                mprintln("Loaded data from local file \(fileName) successfully.")
            }
            return dataVal
            
        } else {
            
            return executeHttpPost(request, fileName: fileName, expectedSuccessCode: expectedSuccessCode, completionHandler: completionHandler)
        }
        
    }
    
    func executeHttpPost(request : NSMutableURLRequest, fileName : String? = nil, expectedSuccessCode : Int = 200, completionHandler: ((NSData?, online: Bool) -> Void)? = nil) -> NSData? {
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode == expectedSuccessCode) {
                mprintln("Post to url \(request.URL) successful.")
                servicesAvailable = true
                writeDataToFile(fileName, data: dataVal!)
                if (completionHandler != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler!(dataVal, online:true)
                    }
                }
                return dataVal
            } else {
                mprintln("Error during post request to url \(request.URL) !")
                dataVal = readDataFromFile(fileName)
                if (completionHandler != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler!(dataVal, online: false)
                    }
                }
                return dataVal
            }
        } else {
            mprintln("Post failed")
            dataVal = readDataFromFile(fileName)
            if (completionHandler != nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler!(dataVal, online: false)
                }
            }
            return dataVal
        }
    
    }
    
    func performQuery(query : String, queryName : String, limit: Int, offset : Int, completionHandler : (([NSDictionary]?) -> Void)? = nil) -> [NSDictionary]? {
        if (!areServicesAvailable()) {
            mprintln("Services not available, attempting to perform query \(query) offline...")
        } else {
            mprintln("Performing query \(query) online...")
        }
        
        let requestString : String = "{\"query\" : \"\(query)\", \"limit\": \(limit), \"offset\":\(offset) }";
        let dataVal = httpPost(jahiaServerSettings.jcrApiUrl() + "/live/en/query", body: requestString, fileName: queryName + ".json", contentType: "application/json", completionHandler: { dataVal,online in
            if let data = dataVal {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var error: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]

                completionHandler!(jsonResult)
            } else {
                self.mprintln("Couldn't retrieve results for query \(query) !")
            }

        })
        
        if let data = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]

            return jsonResult
        } else {
            mprintln("Couldn't retrieve results for query \(query) !")
        }
        return nil
    }
    
    func performPreparedQuery(queryName : String, queryParameters : [AnyObject]) {
        
    }
    
    func getApiVersion(completionHandler : (([String:AnyObject]?) -> Void)? = nil) -> [String:AnyObject]? {
        mprintln("Retrieving API version...")
        let dataVal = httpGet(jahiaServerSettings.jcrApiUrl() + "/version", fileName: "apiVersion.json", completionHandler : { dataVal,online in
            if let versionData = dataVal {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var error: NSError?
                let version = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as? [String:AnyObject]
                if (completionHandler != nil) {
                    completionHandler!(version)
                }
            }
        })
        if let versionData = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            let version = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as? [String:AnyObject]
            return version
        }
        return nil
    }
    
    func login() -> Bool {
        
        var result : Bool = false
        mprintln("Logging into Jahia...")
        
        let requestString : String = "doLogin=true&restMode=true&username=\(jahiaServerSettings.jahiaUserName)&password=\(jahiaServerSettings.jahiaPassword)&redirectActive=false";
        let dataVal = httpPost(jahiaServerSettings.loginUrl(), body:requestString, fileName: "login.txt", completionHandler: { dataVal,online in
            if let data = dataVal {
                self.mprintln("Login successful.")
                self.servicesAvailable = true
                self.loggedIn = true
                let userPath = self.getUserPath(completionHandler: { userPath in
                    if let realUserPath = userPath {
                        self.jahiaServerSettings.jahiaUserPath = realUserPath
                    }
                })
                if let realUserPath = userPath {
                    self.jahiaServerSettings.jahiaUserPath = realUserPath
                }
                result = true
            } else {
                self.mprintln("Login failed")
                self.loggedIn = false
            }
        })
        
        if let data = dataVal {
            mprintln("Login successful.")
            servicesAvailable = true
            loggedIn = true
            let userPath = getUserPath()
            if let realUserPath = userPath {
                jahiaServerSettings.jahiaUserPath = realUserPath
            }
            result = true
        } else {
            mprintln("Login failed")
            loggedIn = false
        }
        hideMessages()
        return result
    }
    
    func areServicesAvailable() -> Bool {
        if (!jcrApiVersionRequested) {
            jcrApiVersionMap = getApiVersion()
            jcrApiVersionRequested = true
            if (jcrApiVersionMap == nil) {
                mprintln("Couldn't get API version, marking services as unavailable")
                servicesAvailable = false
                return servicesAvailable
            } else {
                jcrApiVersion = jcrApiVersionMap!["api"] as! String?
                jcrApiModuleVersion = jcrApiVersionMap!["module"] as! String?
            }
        } else {
            if (jcrApiVersionMap == nil) {
                return servicesAvailable
            }
        }
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
        
        let dataVal = httpGet(jahiaServerSettings.registerDeviceTokenUrl() + "?deviceToken=\(escapedDeviceToken)", fileName: "registerDeviceToken.txt")
        
        if let result = dataVal {
            mprintln("Device token \(deviceToken) successfully registered on Jahia server for the current user")
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
        
        let jahiaBlockUserURL : NSURL = NSURL(string: jahiaServerSettings.blockUserUrl() + "?userName=\(userName)")!
        
        let request = NSMutableURLRequest(URL: jahiaBlockUserURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 4
        
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

    func unblockUser(userName : String) {
        if (!areServicesAvailable()) {
            return
        }
        mprintln("Unblocking user...")
        
        let jahiaUnblockUserURL : NSURL = NSURL(string: jahiaServerSettings.unblockUserUrl() + "?userName=\(userName)")!
        
        let request = NSMutableURLRequest(URL: jahiaUnblockUserURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 4
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error unblocking user \(userName)?")
            } else {
                mprintln("User \(userName) unblocked successfully.")
            }
        } else {
            mprintln("Unblocking of user \(userName) failed")
        }
        hideMessages()
    }
    
    func markAsSpam(nodeIdentifier : String) {
        if (!areServicesAvailable()) {
            return
        }
        mprintln("Marking post as spam")
        
        let jahiaMarkAsSpamURL : NSURL = NSURL(string: jahiaServerSettings.markAsSpamUrl() + "?nodeIdentifier=\(nodeIdentifier)")!
        
        let request = NSMutableURLRequest(URL: jahiaMarkAsSpamURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 4
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error marking post as spam ?")
            } else {
                mprintln("Post marked as spam successfully.")
            }
        } else {
            mprintln("Marking post as spam failed")
        }
        hideMessages()
    }

    func unmarkAsSpam(nodeIdentifier : String) {
        if (!areServicesAvailable()) {
            return
        }
        mprintln("Unmarking post as spam")
        
        let jahiaUnmarkAsSpamURL : NSURL = NSURL(string: jahiaServerSettings.unmarkAsSpamUrl() + "?nodeIdentifier=\(nodeIdentifier)")!
        
        let request = NSMutableURLRequest(URL: jahiaUnmarkAsSpamURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 4
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error unmarking post as spam ?")
            } else {
                mprintln("Post unmarked as spam successfully.")
            }
        } else {
            mprintln("Unmarking post as spam failed")
        }
        hideMessages()
    }
    
    func deleteNode(nodeIdentifier : String, workspace : String) {
        if (!areServicesAvailable()) {
            return
        }
        mprintln("Deleting node \(nodeIdentifier)")
        
        let jahiaDeleteNodeURL : NSURL = NSURL(string: jahiaServerSettings.jcrApiUrl() + "/\(workspace)/en/nodes/\(nodeIdentifier)")!
        
        let request = NSMutableURLRequest(URL: jahiaDeleteNodeURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 4
        request.HTTPMethod = "DELETE"
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 204) {
                mprintln("Error deleting node \(nodeIdentifier) statusCode=\(httpResponse.statusCode)")
            } else {
                mprintln("Node \(nodeIdentifier) deleted successfully.")
            }
        } else {
            mprintln("Deleting node \(nodeIdentifier) failed.")
        }
        hideMessages()
    }
    
    func getPostActions(post : Post) -> Post {
        if (!areServicesAvailable()) {
            return post
        }
        mprintln("Retrieving post actions...")
        
        let jahiaPostActionsURL : NSURL = NSURL(string: jahiaServerSettings.postActionsUrl(post.path!))!
        
        let request = NSMutableURLRequest(URL: jahiaPostActionsURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error retrieving post actions!")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                if let viewUrl = jsonResult["view-url"] as? String {
                    post.viewUrl = viewUrl
                }
                if let possibleActions = jsonResult["possibleActions"] as? [NSDictionary] {
                    var actions = [PostAction]()
                    for possibleAction in possibleActions {
                        let postAction = PostAction()
                        postAction.displayName = possibleAction["displayName"] as? String
                        postAction.name = possibleAction["name"] as? String
                        actions.append(postAction)
                    }
                    post.actions = actions
                } else {
                    post.actions = nil
                }
            }
        } else {
            mprintln("Couldn't retrieve post actions")
        }
        
        hideMessages()
        return post
    }
    
    
    func getUserPath(completionHandler : ((String?) -> Void)? = nil) -> String? {
        if (!areServicesAvailable()) {
            return ""
        }
        mprintln("Retrieving current user path...")
        
        let dataVal = httpGet(jahiaServerSettings.userPathUrl(), fileName: "userPath.txt", completionHandler: {dataVal, online in
            if let data = dataVal {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                self.hideMessages()
                if completionHandler != nil {
                    completionHandler!(JahiaServerServices.condenseWhitespace(datastring! as String))
                }
            } else {
                self.mprintln("Coudln't retrieve current user path")
            }
        })

        if let data = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            hideMessages()
            return JahiaServerServices.condenseWhitespace(datastring! as String)
        } else {
            mprintln("Coudln't retrieve current user path")
        }
        hideMessages()
        return nil;
    }
    
    func getWorkflowTasks(completionHandler: (([Task]?) -> Void)? = nil) -> [Task] {
        var taskArray = [Task]()
        if (!areServicesAvailable()) {
            mprintln("Probably offline, retrieving workflow tasks from local cache...")
        } else {
            mprintln("Retrieving workflow tasks...")
        }
        
        let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(jahiaServerSettings.jahiaUserPath)/workflowTasks?includeFullChildren&resolveReferences")!
        
        let dataVal = httpGet(jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(jahiaServerSettings.jahiaUserPath)/workflowTasks?includeFullChildren&resolveReferences", fileName:"workflow-tasks.json", completionHandler : { dataVal,online in
            if let data = dataVal {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var error: NSError?
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                let workflowTasksChildren = jsonResult["children"] as! NSDictionary
                
                let workflowTaskChildrenDict = workflowTasksChildren as! [String:NSDictionary]
                
                for (key,value) in workflowTaskChildrenDict {
                    let task = Task(taskName: key, fromNSDictionary: value)
                    if (task.state != "Finished") {
                        taskArray.append(task)
                    }
                }
            } else {
                self.mprintln("Couldn't retrieve workflow tasks")
            }
        })
        
        if let data = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
            
            let workflowTasksChildren = jsonResult["children"] as! NSDictionary
            
            let workflowTaskChildrenDict = workflowTasksChildren as! [String:NSDictionary]
            
            for (key,value) in workflowTaskChildrenDict {
                let task = Task(taskName: key, fromNSDictionary: value)
                if (task.state != "Finished") {
                    taskArray.append(task)
                }
            }
        } else {
            mprintln("Couldn't retrieve workflow tasks")
        }
        hideMessages()
        return taskArray
    }
    
    func refreshTask(task : Task) -> Task? {
        if (!areServicesAvailable()) {
            return task
        }
        
        mprintln("Refreshing task \(task.path) ...")

        let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(task.path!)?includeFullChildren&resolveReferences")!
        
        let request = NSMutableURLRequest(URL: jahiaWorkflowTasksURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                mprintln("Error retrieving updated task!")
            } else {
                writeDataToFile("task-\(task.identifier).json", data: dataVal!)
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

        let jahiaTaskActionsURL : NSURL = NSURL(string: jahiaServerSettings.taskActionsUrl(task.path!))!
        
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
                } else {
                    task.nextActions = nil
                }
            }
        } else {
            mprintln("Couldn't retrieve task actions")
        }
        
        hideMessages()
        return task
    }
    
    func performTaskAction(task: Task, actionName : String, finalOutcome : String?) -> Bool {
        var result = false
        mprintln("Sending task action \(actionName) with outcome \(finalOutcome) to Jahia server...")
        
        let jahiaTaskActionsURL : NSURL = NSURL(string: jahiaServerSettings.taskActionsUrl(task.path!))!
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
                result = true
            }
        } else {
            mprintln("Action sending failed")
        }
        hideMessages()
        return result
    }
    
    func getLatestPosts(completionHandler : (([Post]) -> Void)? = nil) -> [Post] {
        var posts = [Post]()
        mprintln("Retrieving latest posts...")
        if (!areServicesAvailable()) {
            mprintln("Services are not available, will try to load offline data if it exists...")
        }
        
        let jsonQueryReply = performQuery("select * from [jnt:post] as p order by p.[jcr:created] desc", queryName: "latest-posts", limit: 20, offset: 0, completionHandler: { jsonQueryReply in
            if let jsonResult = jsonQueryReply {
                
                for postDict in jsonResult {
                    let post = Post(fromNSDictionary: postDict)
                    posts.append(post)
                }
            } else {
                self.mprintln("Couldn't retrieve latest posts!")
            }
        })

        if let jsonResult = jsonQueryReply {

            for postDict in jsonResult {
                let post = Post(fromNSDictionary: postDict)
                posts.append(post)
            }                
        } else {
            mprintln("Couldn't retrieve latest posts!")
        }
        hideMessages()
        return posts
        
    }
    
    func refreshPost(post : Post) -> Post? {
        if (!areServicesAvailable()) {
            return post
        }
        mprintln("Refreshing post \(post.path!) ...")
        
        let jahiaGetPostURL : NSURL = NSURL(string: jahiaServerSettings.jcrApiUrl() + "/live/en/paths\(post.path!)?includeFullChildren&resolveReferences")!
        
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
    
    func jsonEscaping(input : String) -> String {
        var s : String = input
        s = s.stringByReplacingOccurrencesOfString("\"",withString:"\\\"",options:NSStringCompareOptions.CaseInsensitiveSearch, range:Range<String.Index>(start: s.startIndex, end: s.endIndex))
        s = s.stringByReplacingOccurrencesOfString("/",withString:"\\/", options:NSStringCompareOptions.CaseInsensitiveSearch, range:Range<String.Index>(start: s.startIndex, end: s.endIndex))
        s = s.stringByReplacingOccurrencesOfString("\n",withString:"\\n", options:NSStringCompareOptions.CaseInsensitiveSearch, range:Range<String.Index>(start: s.startIndex, end: s.endIndex))
        s = s.stringByReplacingOccurrencesOfString("\r",withString:"\\r", options:NSStringCompareOptions.CaseInsensitiveSearch, range:Range<String.Index>(start: s.startIndex, end: s.endIndex))
        s = s.stringByReplacingOccurrencesOfString("\t",withString:"\\t", options:NSStringCompareOptions.CaseInsensitiveSearch, range:Range<String.Index>(start: s.startIndex, end: s.endIndex))
        return s
    }
    
    func replyToPost(post : Post, title : String?, body : String?) -> Post? {
        if (!areServicesAvailable()) {
            return post
        }
        mprintln("Replying to post \(post.path!) ...")
        
        let regex = NSRegularExpression(
            pattern: "[^0-9a-zA-Z]",
            options: NSRegularExpressionOptions.CaseInsensitive,
            error: nil)!
        
        let range = NSMakeRange(0, count(title!))
        let newNodeName : String = regex.stringByReplacingMatchesInString(title!,
            options: NSMatchingOptions.allZeros,
            range:range ,
            withTemplate: "")
        
        let jahiaReplyPostURL : NSURL = NSURL(string: jahiaServerSettings.contextUrl() + "/modules" + post.parentUri! + "/children/" + newNodeName)!
        
        let request = NSMutableURLRequest(URL: jahiaReplyPostURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData

        let requestString : String = "{\"type\" : \"jnt:post\", \"properties\": { \"jcr:title\" : { \"value\" : \"\(jsonEscaping(title!))\" }, \"content\" : { \"value\" : \"\(jsonEscaping(body!))\" } } }";
        mprintln("PUT \(jahiaReplyPostURL)")
        mprintln("payload=\(requestString)")
        let postData = NSMutableData()
        postData.appendData(requestString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPMethod = "PUT"
        request.setValue(NSString(format: "%lu", postData.length) as String, forHTTPHeaderField: "Content-Length")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var openTaskCount = 0;
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode != 201) {
                mprintln("Error creating child post under\(post.path) statusCode=\(httpResponse.statusCode)")
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                mprintln("result=\(datastring)")
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
        
    class func stripHTML(input : String, stripExtraWhiteSpace : Bool) -> String {
        var output = input.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        output = output.stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
        output = output.stringByReplacingOccurrencesOfString("&quote;", withString: "'")
        output = output.stringByReplacingOccurrencesOfString("&rsquo;", withString: "'")
        output = output.stringByReplacingOccurrencesOfString("&#39;", withString: "'")
        output = output.stringByReplacingOccurrencesOfString("&amp;", withString: "&")
        if (stripExtraWhiteSpace) {
            output = output.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
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