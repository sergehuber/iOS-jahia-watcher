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
            (dataVal,online) = jahiaServerServices.httpRequest(jahiaServerSettings.jcrApiUrl() + "/live/en/query", body: requestString, fileName: queryName + ".json", contentType: "application/json")
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
    
    func performPreparedQuery(queryName : String, queryParameters : [String:AnyObject], limit: Int, offset : Int) -> ([NSDictionary]?,Bool) {
        var dataVal : NSData?
        var online = false
        
        if (!areServicesAvailable()) {
            jahiaServerServices.mprintln("Services not available, attempting to perform query \(queryName) offline...")
            let fileName = queryName + ".json"
            dataVal = jahiaServerServices.readDataFromFile(fileName)
        } else {
            jahiaServerServices.mprintln("Performing query named \(queryName) with named parameters online...")
            var queryParamPart : String = "{"
            var count = 0
            for (paramName,paramValue) in queryParameters {
                queryParamPart += "\"\(paramName)\" : \"\(paramValue)\" "
                count++
                if (count < queryParameters.count) {
                    queryParamPart + ","
                }
            }
            queryParamPart += "}"
            let requestString : String = "{\"queryName\" : \"\(queryName)\", \"namedParameters\": \(queryParamPart), \"limit\": \(limit), \"offset\":\(offset) }";
            (dataVal,online) = jahiaServerServices.httpRequest(jahiaServerSettings.jcrApiUrl() + "/live/en/query", body: requestString, fileName: queryName + ".json", contentType: "application/json")
        }
        
        if let data = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]
            
            return (jsonResult,online)
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve results for query named \(queryName) !")
        }
        return (nil,false)
        
    }

    func performPreparedQuery(queryName : String, queryParameters : [AnyObject], limit: Int, offset : Int) -> ([NSDictionary]?,Bool) {
        var dataVal : NSData?
        var online = false
        
        if (!areServicesAvailable()) {
            jahiaServerServices.mprintln("Services not available, attempting to perform query \(queryName) offline...")
            let fileName = queryName + ".json"
            dataVal = jahiaServerServices.readDataFromFile(fileName)
        } else {
            jahiaServerServices.mprintln("Performing query named \(queryName) with parameter array online...")
            var queryParamPart : String = "["
            var count = 0
            for paramValue in queryParameters {
                queryParamPart += "\"\(paramValue)\" "
                count++
                if (count < queryParameters.count) {
                    queryParamPart + ","
                }
            }
            queryParamPart += "]"
            let requestString : String = "{\"queryName\" : \"\(queryName)\", \"parameters\": \(queryParamPart), \"limit\": \(limit), \"offset\":\(offset) }";
            (dataVal,online) = jahiaServerServices.httpRequest(jahiaServerSettings.jcrApiUrl() + "/live/en/query", body: requestString, fileName: queryName + ".json", contentType: "application/json")
        }
        
        if let data = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]
            
            return (jsonResult,online)
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve results for query named \(queryName) !")
        }
        return (nil,false)
        
    }
    
    func getApiVersion() -> [String:AnyObject]? {
        jahiaServerServices.mprintln("Retrieving API version...")
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/version", fileName: "apiVersion.json", timeoutInterval: 1)
        servicesAvailable = online
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
        let (dataVal,online) = jahiaServerServices.httpRequest(jahiaServerSettings.loginUrl(), body:requestString, fileName: "login.txt")
        
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
                if (!servicesAvailable) {
                    return servicesAvailable
                }
            }
        } else {
            if (jcrApiVersionMap == nil) {
                return servicesAvailable
            }
        }
        if (!servicesAvailable) {
            return servicesAvailable
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
        
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.blockUserUrl() + "?userName=\(userName)")
        if let result = dataVal {
            jahiaServerServices.mprintln("User \(userName) blocked successfully.")
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
        
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.unblockUserUrl() + "?userName=\(userName)")
        if let result = dataVal {
            jahiaServerServices.mprintln("User \(userName) unblocked successfully.")
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
        
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.markAsSpamUrl() + "?nodeIdentifier=\(nodeIdentifier)")
        if let result = dataVal {
            jahiaServerServices.mprintln("Post marked as spam successfully.")
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
        
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.unmarkAsSpamUrl() + "?nodeIdentifier=\(nodeIdentifier)")
        if let result = dataVal {
            jahiaServerServices.mprintln("Post unmarked as spam successfully.")
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
        
        let (dataVal,online) = jahiaServerServices.httpRequest(jahiaServerSettings.jcrApiUrl() + "/\(workspace)/en/nodes/\(nodeIdentifier)", expectedSuccessCode: 204, httpMethod : "DELETE")
        if let result = dataVal {
            jahiaServerServices.mprintln("Node \(nodeIdentifier) deleted successfully.")
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
        
        var error : NSError?
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.postActionsUrl(post.path!))
        if let result = dataVal {
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
        
        var error : NSError?
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(task.path!)?includeFullChildren&resolveReferences")
        if let result = dataVal {
            jahiaServerServices.writeDataToFile("task-\(task.identifier).json", data: dataVal!)
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
            
            jahiaServerServices.hideMessages()
            return Task(taskName: task.name!, fromNSDictionary: jsonResult)
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
        
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(task.path!)?includeFullChildren&resolveReferences")
        if let result = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error : NSError?
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
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve task actions")
        }
        
        jahiaServerServices.hideMessages()
        return task
    }
    
    func performTaskAction(task: Task, actionName : String, finalOutcome : String?) -> Bool {
        var result = false
        jahiaServerServices.mprintln("Sending task action \(actionName) with outcome \(finalOutcome) to Jahia server...")
        
        let requestString : String = "action=\(actionName)" + ((finalOutcome != nil) ? "&finalOutcome=\(finalOutcome!)" : "");
        let (dataVal,online) = jahiaServerServices.httpRequest(jahiaServerSettings.taskActionsUrl(task.path!), body: requestString)
        if let dataResult = dataVal {
            jahiaServerServices.mprintln("Action sent successfully.")
            result = true
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
        
        if (jahiaServerSettings.jahiaUsePreparedQueries) {
            jahiaServerServices.mprintln("Using prepary queries...")
            (jsonQueryReply,online) = performPreparedQuery("latestPosts", queryParameters: [String:AnyObject](), limit: 20, offset: 0)
            /*
            (jsonQueryReply,online) = performPreparedQuery("latestPosts", queryParameters: [], limit: 20, offset: 0)
            */
        } else {
            (jsonQueryReply,online) = performQuery("select * from [jnt:post] as p order by p.[jcr:created] desc", queryName: "latestPosts", limit: 20, offset: 0)
        }
        
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
        
        let (dataVal,online) = jahiaServerServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/live/en/paths\(post.path!)?includeFullChildren&resolveReferences")
        if let result = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error : NSError?
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
            
            jahiaServerServices.hideMessages()
            return Post(fromNSDictionary: jsonResult)
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
        
        let requestString : String = "{\"type\" : \"jnt:post\", \"properties\": { \"jcr:title\" : { \"value\" : \"\(jahiaServerServices.jsonEscaping(title!))\" }, \"content\" : { \"value\" : \"\(jahiaServerServices.jsonEscaping(body!))\" } } }";
        jahiaServerServices.mprintln("payload=\(requestString)")
        let (dataVal,online) = jahiaServerServices.httpRequest(jahiaServerSettings.contextUrl() + "/modules" + post.parentUri! + "/children/" + newNodeName, body: requestString, contentType : "application/json", expectedSuccessCode: 201, httpMethod: "PUT")
        if let dataResult = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
            
            jahiaServerServices.hideMessages()
            return Post(fromNSDictionary: jsonResult)
        } else {
            jahiaServerServices.mprintln("Couldn't retrieve update for post \(post.path)")
        }
        jahiaServerServices.hideMessages()
        return nil
    }

    
    func logout() {
        
    }
}