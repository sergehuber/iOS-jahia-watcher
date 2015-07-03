//
//  JahiaServerSession.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 01.07.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class JahiaServerSession {
    let jahiaServerSettings : JahiaServerSettings = JahiaServerSettings.sharedInstance
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance

    var online : Bool = false
    var servicesAvailable : Bool = false
    var loggedIn : Bool = false
    var lastConnectionAttemptTime : NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
    var attemptedLogin : Bool = false
    var jcrApiVersionMap : [String:AnyObject]? = nil
    var jcrApiVersion : String? = nil
    var jcrApiModuleVersion : String? = nil
    var jcrApiVersionRequested = false
        
    func performQuery(query : String, queryName : String, limit: Int, offset : Int) -> ([NSDictionary]?,Bool) {
        
        var dataVal : NSData?
        var online = false
        
        if (!areServicesAvailable()) {
            jahiaServerServices.mprintln("Services not available, attempting to perform query \(query) offline...")
            let fileName = queryName + ".json"
            dataVal = jahiaServerServices.readDataFromFile(fileName)
        } else {
            jahiaServerServices.mprintln("Performing query \(query) online...")
            let requestString : String = "{\"query\" : \"\(query)\", \"limit\": \(limit), \"offset\":\(offset) }";
            (dataVal,online) = jahiaServerServices.httpPost(jahiaServerSettings.jcrApiUrl() + "/live/en/query", body: requestString, fileName: queryName + ".json", contentType: "application/json")
        }
        
        if let data = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]
            
            return (jsonResult,online)
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve results for query \(query) !")
        }
        return (nil,false)
    }
    
    func performPreparedQuery(queryName : String, queryParameters : [AnyObject]) {
        
    }
    
    func getApiVersion() -> [String:AnyObject]? {
        jahiaServerServices.mprintln("Retrieving API version...")
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/version", fileName: "apiVersion.json", timeoutInterval: 2)
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
        jahiaServerServices.mprintln("Logging into Jahia...")
        
        let requestString : String = "doLogin=true&restMode=true&username=\(jahiaServerSettings.jahiaUserName)&password=\(jahiaServerSettings.jahiaPassword)&redirectActive=false";
        let (dataVal,online) = jahiaServerServices.httpPost(jahiaServerSettings.loginUrl(), body:requestString, fileName: "login.txt")
        
        if let data = dataVal {
            jahiaServerServices.mprintln("Login successful.")
            servicesAvailable = true
            loggedIn = true
            let userPath = getUserPath()
            if let realUserPath = userPath {
                jahiaServerSettings.jahiaUserPath = realUserPath
            }
            result = true
        } else {
            jahiaServerServices.mprintln("Login failed")
            loggedIn = false
        }
        jahiaServerServices.hideMessages()
        return result
    }
    
    func areServicesAvailable() -> Bool {
        if (!jcrApiVersionRequested) {
            jcrApiVersionMap = getApiVersion()
            jcrApiVersionRequested = true
            if (jcrApiVersionMap == nil) {
                jahiaServerServices.mprintln("Couldn't get API version, marking services as unavailable")
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
            jahiaServerServices.mprintln("Services not available")
            return false
        }
        return true;
    }
    
    func registerDeviceToken(deviceToken : String) {
        if (!areServicesAvailable()) {
            return
        }
        jahiaServerServices.mprintln("Registering device token...")
        let escapedDeviceToken : String = deviceToken.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.registerDeviceTokenUrl() + "?deviceToken=\(escapedDeviceToken)", fileName: "registerDeviceToken.txt")
        
        if let result = dataVal {
            jahiaServerServices.mprintln("Device token \(deviceToken) successfully registered on Jahia server for the current user")
        } else {
            jahiaServerServices.mprintln("Device registration failed")
        }
        jahiaServerServices.hideMessages()
    }
    
    func blockUser(userName : String) {
        if (!areServicesAvailable()) {
            return
        }
        jahiaServerServices.mprintln("Blocking user...")
        
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
                jahiaServerServices.mprintln("Error blocking user \(userName)?")
            } else {
                jahiaServerServices.mprintln("User \(userName) blocked successfully.")
            }
        } else {
            jahiaServerServices.mprintln("Blocking of user \(userName) failed")
        }
        jahiaServerServices.hideMessages()
    }
    
    func unblockUser(userName : String) {
        if (!areServicesAvailable()) {
            return
        }
        jahiaServerServices.mprintln("Unblocking user...")
        
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
                jahiaServerServices.mprintln("Error unblocking user \(userName)?")
            } else {
                jahiaServerServices.mprintln("User \(userName) unblocked successfully.")
            }
        } else {
            jahiaServerServices.mprintln("Unblocking of user \(userName) failed")
        }
        jahiaServerServices.hideMessages()
    }
    
    func markAsSpam(nodeIdentifier : String) {
        if (!areServicesAvailable()) {
            return
        }
        jahiaServerServices.mprintln("Marking post as spam")
        
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
                jahiaServerServices.mprintln("Error marking post as spam ?")
            } else {
                jahiaServerServices.mprintln("Post marked as spam successfully.")
            }
        } else {
            jahiaServerServices.mprintln("Marking post as spam failed")
        }
        jahiaServerServices.hideMessages()
    }
    
    func unmarkAsSpam(nodeIdentifier : String) {
        if (!areServicesAvailable()) {
            return
        }
        jahiaServerServices.mprintln("Unmarking post as spam")
        
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
                jahiaServerServices.mprintln("Error unmarking post as spam ?")
            } else {
                jahiaServerServices.mprintln("Post unmarked as spam successfully.")
            }
        } else {
            jahiaServerServices.mprintln("Unmarking post as spam failed")
        }
        jahiaServerServices.hideMessages()
    }
    
    func deleteNode(nodeIdentifier : String, workspace : String) {
        if (!areServicesAvailable()) {
            return
        }
        jahiaServerServices.mprintln("Deleting node \(nodeIdentifier)")
        
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
                jahiaServerServices.mprintln("Error deleting node \(nodeIdentifier) statusCode=\(httpResponse.statusCode)")
            } else {
                jahiaServerServices.mprintln("Node \(nodeIdentifier) deleted successfully.")
            }
        } else {
            jahiaServerServices.mprintln("Deleting node \(nodeIdentifier) failed.")
        }
        jahiaServerServices.hideMessages()
    }
    
    func getPostActions(post : Post) -> Post {
        if (!areServicesAvailable()) {
            return post
        }
        jahiaServerServices.mprintln("Retrieving post actions...")
        
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
                jahiaServerServices.mprintln("Error retrieving post actions!")
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
            jahiaServerServices.mprintln("Couldn't retrieve post actions")
        }
        
        jahiaServerServices.hideMessages()
        return post
    }
    
    
    func getUserPath() -> String? {
        if (!areServicesAvailable()) {
            return jahiaServerServices.readStringFromFile("userPath.txt")
        }
        jahiaServerServices.mprintln("Retrieving current user path...")
        
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.userPathUrl(), fileName: "userPath.txt")
        
        if let data = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            jahiaServerServices.hideMessages()
            return JahiaServerServices.condenseWhitespace(datastring! as String)
        } else {
            jahiaServerServices.mprintln("Coudln't retrieve current user path")
        }
        jahiaServerServices.hideMessages()
        return nil;
    }
    
    func getWorkflowTasks() -> [Task] {
        var taskArray = [Task]()
        var dataVal : NSData?
        var online : Bool = false
        if (!areServicesAvailable()) {
            jahiaServerServices.mprintln("Probably offline, retrieving workflow tasks from local cache...")
            dataVal = jahiaServerServices.readDataFromFile("workflow-tasks.json")
        } else {
            jahiaServerServices.mprintln("Retrieving workflow tasks...")
            let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(jahiaServerSettings.jahiaUserPath)/workflowTasks?includeFullChildren&resolveReferences")!
            
            (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(jahiaServerSettings.jahiaUserPath)/workflowTasks?includeFullChildren&resolveReferences", fileName:"workflow-tasks.json")
        }
        
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
            jahiaServerServices.mprintln("Couldn't retrieve workflow tasks")
        }
        jahiaServerServices.hideMessages()
        return taskArray
    }
    
    func refreshTask(task : Task) -> Task? {
        if (!areServicesAvailable()) {
            return task
        }
        
        jahiaServerServices.mprintln("Refreshing task \(task.path) ...")
        
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
                jahiaServerServices.mprintln("Error retrieving updated task!")
            } else {
                jahiaServerServices.writeDataToFile("task-\(task.identifier).json", data: dataVal!)
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                jahiaServerServices.hideMessages()
                return Task(taskName: task.name!, fromNSDictionary: jsonResult)
                
            }
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve task")
        }
        jahiaServerServices.hideMessages()
        return nil
    }
    
    func getTaskActions(task : Task) -> Task {
        if (!areServicesAvailable()) {
            return task
        }
        jahiaServerServices.mprintln("Retrieving task actions...")
        
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
                jahiaServerServices.mprintln("Error retrieving task actions!")
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
            jahiaServerServices.mprintln("Couldn't retrieve task actions")
        }
        
        jahiaServerServices.hideMessages()
        return task
    }
    
    func performTaskAction(task: Task, actionName : String, finalOutcome : String?) -> Bool {
        var result = false
        jahiaServerServices.mprintln("Sending task action \(actionName) with outcome \(finalOutcome) to Jahia server...")
        
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
                jahiaServerServices.mprintln("Action sent successfully.")
                result = true
            }
        } else {
            jahiaServerServices.mprintln("Action sending failed")
        }
        jahiaServerServices.hideMessages()
        return result
    }
    
    func getLatestPosts() -> [Post] {
        var posts = [Post]()
        jahiaServerServices.mprintln("Retrieving latest posts...")
        
        var jsonQueryReply : [NSDictionary]?
        var online = false
        
        (jsonQueryReply,online) = performQuery("select * from [jnt:post] as p order by p.[jcr:created] desc", queryName: "latest-posts", limit: 20, offset: 0)
        
        if let jsonResult = jsonQueryReply {
            
            for postDict in jsonResult {
                let post = Post(fromNSDictionary: postDict)
                posts.append(post)
            }
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve latest posts!")
        }
        jahiaServerServices.hideMessages()
        return posts
        
    }
    
    func refreshPost(post : Post) -> Post? {
        if (!areServicesAvailable()) {
            return post
        }
        jahiaServerServices.mprintln("Refreshing post \(post.path!) ...")
        
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
                jahiaServerServices.mprintln("Error retrieving post \(post.path)")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                jahiaServerServices.hideMessages()
                return Post(fromNSDictionary: jsonResult)
                
            }
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve update for post \(post.path)")
        }
        jahiaServerServices.hideMessages()
        return nil
        
    }
    
    func replyToPost(post : Post, title : String?, body : String?) -> Post? {
        if (!areServicesAvailable()) {
            return post
        }
        jahiaServerServices.mprintln("Replying to post \(post.path!) ...")
        
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
        
        let requestString : String = "{\"type\" : \"jnt:post\", \"properties\": { \"jcr:title\" : { \"value\" : \"\(jahiaServerServices.jsonEscaping(title!))\" }, \"content\" : { \"value\" : \"\(jahiaServerServices.jsonEscaping(body!))\" } } }";
        jahiaServerServices.mprintln("PUT \(jahiaReplyPostURL)")
        jahiaServerServices.mprintln("payload=\(requestString)")
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
                jahiaServerServices.mprintln("Error creating child post under\(post.path) statusCode=\(httpResponse.statusCode)")
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                jahiaServerServices.mprintln("result=\(datastring)")
            } else {
                var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                jahiaServerServices.hideMessages()
                return Post(fromNSDictionary: jsonResult)
                
            }
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve update for post \(post.path)")
        }
        jahiaServerServices.hideMessages()
        return nil
    }

    
    func logout() {
        
    }
}