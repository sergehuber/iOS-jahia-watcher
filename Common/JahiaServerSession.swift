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
    let contextServerSettings : ContextServerSettings = ContextServerSettings.sharedInstance
    let serverServices : ServerServices = ServerServices.sharedInstance

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
            serverServices.mprintln("Services not available, attempting to perform query \(query) offline...")
            let fileName = queryName + ".json"
            dataVal = serverServices.readDataFromFile(fileName)
        } else {
            serverServices.mprintln("Performing query \(query) online...")
            let requestString : String = "{\"query\" : \"\(query)\", \"limit\": \(limit), \"offset\":\(offset) }";
            (dataVal,online) = serverServices.httpRequest(jahiaServerSettings.jcrApiUrl() + "/live/en/query", body: requestString, fileName: queryName + ".json", contentType: "application/json")
        }
        
        if let data = dataVal {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! [NSDictionary]
            
            return (jsonResult,online)
        } else {
            serverServices.mprintln("Couldn't retrieve results for query \(query) !")
        }
        return (nil,false)
    }
    
    func performPreparedQuery(queryName : String, queryParameters : [String:AnyObject], limit: Int, offset : Int) -> ([NSDictionary]?,Bool) {
        var dataVal : NSData?
        var online = false
        
        if (!areServicesAvailable()) {
            serverServices.mprintln("Services not available, attempting to perform query \(queryName) offline...")
            let fileName = queryName + ".json"
            dataVal = serverServices.readDataFromFile(fileName)
        } else {
            serverServices.mprintln("Performing query named \(queryName) with named parameters online...")
            var queryParamPart : String = "{"
            var count = 0
            for (paramName,paramValue) in queryParameters {
                queryParamPart += "\"\(paramName)\" : \"\(paramValue)\" "
                count++
                if (count < queryParameters.count) {
                    queryParamPart += ","
                }
            }
            queryParamPart += "}"
            let requestString : String = "{\"queryName\" : \"\(queryName)\", \"namedParameters\": \(queryParamPart), \"limit\": \(limit), \"offset\":\(offset) }";
            (dataVal,online) = serverServices.httpRequest(jahiaServerSettings.jcrApiUrl() + "/live/en/query", body: requestString, fileName: queryName + ".json", contentType: "application/json")
        }
        
        if let data = dataVal {
            var datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! [NSDictionary]
            
            return (jsonResult,online)
        } else {
            serverServices.mprintln("Couldn't retrieve results for query named \(queryName) !")
        }
        return (nil,false)
        
    }

    func performPreparedQuery(queryName : String, queryParameters : [AnyObject], limit: Int, offset : Int) -> ([NSDictionary]?,Bool) {
        var dataVal : NSData?
        var online = false
        
        if (!areServicesAvailable()) {
            serverServices.mprintln("Services not available, attempting to perform query \(queryName) offline...")
            let fileName = queryName + ".json"
            dataVal = serverServices.readDataFromFile(fileName)
        } else {
            serverServices.mprintln("Performing query named \(queryName) with parameter array online...")
            var queryParamPart : String = "["
            var count = 0
            for paramValue in queryParameters {
                queryParamPart += "\"\(paramValue)\" "
                count++
                if (count < queryParameters.count) {
                    queryParamPart += ","
                }
            }
            queryParamPart += "]"
            let requestString : String = "{\"queryName\" : \"\(queryName)\", \"parameters\": \(queryParamPart), \"limit\": \(limit), \"offset\":\(offset) }";
            (dataVal,online) = serverServices.httpRequest(jahiaServerSettings.jcrApiUrl() + "/live/en/query", body: requestString, fileName: queryName + ".json", contentType: "application/json")
        }
        
        if let data = dataVal {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! [NSDictionary]
            
            return (jsonResult,online)
        } else {
            serverServices.mprintln("Couldn't retrieve results for query named \(queryName) !")
        }
        return (nil,false)
        
    }
    
    func getApiVersion() -> [String:AnyObject]? {
        serverServices.mprintln("Retrieving API version...")
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/version", fileName: "apiVersion.json", timeoutInterval: 1)
        servicesAvailable = online
        if let versionData = dataVal {
            var datastring = NSString(data: versionData, encoding: NSUTF8StringEncoding)
            do {
            let version = try NSJSONSerialization.JSONObjectWithData(versionData, options: NSJSONReadingOptions.MutableContainers) as? [String:AnyObject]
                return version
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func login() -> Bool {
        
        var result : Bool = false
        serverServices.mprintln("Logging into Jahia...")
        
        let requestBody : String = "doLogin=true&restMode=true&username=\(jahiaServerSettings.jahiaUserName)&password=\(jahiaServerSettings.jahiaPassword)&redirectActive=false&site=ACMESPACE";
        var loginUrl = jahiaServerSettings.loginUrl()
        if (contextServerSettings.contextServerSessionId != nil) {
            loginUrl = jahiaServerSettings.loginUrl() + "?wemSessionId=\(contextServerSettings.contextServerSessionId!)"
        }
        let (dataVal,online) = serverServices.httpRequest(loginUrl, body:requestBody, fileName: "login.txt")
        
        if let data = dataVal {
            serverServices.mprintln("Login successful.")
            servicesAvailable = true
            loggedIn = true
            let userPath = getUserPath()
            if let realUserPath = userPath {
                jahiaServerSettings.jahiaUserPath = realUserPath
            }
            result = true
        } else {
            serverServices.mprintln("Login failed")
            loggedIn = false
        }
        serverServices.hideMessages()
        return result
    }
    
    func areServicesAvailable() -> Bool {
        if (!jcrApiVersionRequested) {
            jcrApiVersionMap = getApiVersion()
            jcrApiVersionRequested = true
            if (jcrApiVersionMap == nil) {
                serverServices.mprintln("Couldn't get API version, marking services as unavailable")
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
            serverServices.mprintln("Services not available")
            return false
        }
        return true;
    }
    
    func registerDeviceToken(deviceToken : String) {
        if (!areServicesAvailable()) {
            return
        }
        serverServices.mprintln("Registering device token...")
        let escapedDeviceToken : String = deviceToken.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.registerDeviceTokenUrl() + "?deviceToken=\(escapedDeviceToken)", fileName: "registerDeviceToken.txt")
        
        if let result = dataVal {
            serverServices.mprintln("Device token \(deviceToken) successfully registered on Jahia server for the current user")
        } else {
            serverServices.mprintln("Device registration failed")
        }
        serverServices.hideMessages()
    }
    
    func blockUser(userName : String) {
        if (!areServicesAvailable()) {
            return
        }
        serverServices.mprintln("Blocking user...")
        
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.blockUserUrl() + "?userName=\(userName)")
        if let result = dataVal {
            serverServices.mprintln("User \(userName) blocked successfully.")
        } else {
            serverServices.mprintln("Blocking of user \(userName) failed")
        }
        serverServices.hideMessages()
    }
    
    func unblockUser(userName : String) {
        if (!areServicesAvailable()) {
            return
        }
        serverServices.mprintln("Unblocking user...")
        
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.unblockUserUrl() + "?userName=\(userName)")
        if let result = dataVal {
            serverServices.mprintln("User \(userName) unblocked successfully.")
        } else {
            serverServices.mprintln("Unblocking of user \(userName) failed")
        }
        serverServices.hideMessages()
    }
    
    func markAsSpam(nodeIdentifier : String) {
        if (!areServicesAvailable()) {
            return
        }
        serverServices.mprintln("Marking post as spam")
        
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.markAsSpamUrl() + "?nodeIdentifier=\(nodeIdentifier)")
        if let result = dataVal {
            serverServices.mprintln("Post marked as spam successfully.")
        } else {
            serverServices.mprintln("Marking post as spam failed")
        }
        serverServices.hideMessages()
    }
    
    func unmarkAsSpam(nodeIdentifier : String) {
        if (!areServicesAvailable()) {
            return
        }
        serverServices.mprintln("Unmarking post as spam")
        
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.unmarkAsSpamUrl() + "?nodeIdentifier=\(nodeIdentifier)")
        if let result = dataVal {
            serverServices.mprintln("Post unmarked as spam successfully.")
        } else {
            serverServices.mprintln("Unmarking post as spam failed")
        }
        serverServices.hideMessages()
    }
    
    func deleteNode(nodeIdentifier : String, workspace : String) {
        if (!areServicesAvailable()) {
            return
        }
        serverServices.mprintln("Deleting node \(nodeIdentifier)")
        
        let (dataVal,online) = serverServices.httpRequest(jahiaServerSettings.jcrApiUrl() + "/\(workspace)/en/nodes/\(nodeIdentifier)", expectedSuccessCode: 204, httpMethod : "DELETE")
        if let result = dataVal {
            serverServices.mprintln("Node \(nodeIdentifier) deleted successfully.")
        } else {
            serverServices.mprintln("Deleting node \(nodeIdentifier) failed.")
        }
        serverServices.hideMessages()
    }
    
    func getPostActions(post : Post) -> Post {
        if (!areServicesAvailable()) {
            return post
        }
        serverServices.mprintln("Retrieving post actions...")
        
        var error : NSError?
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.postActionsUrl(post.path!))
        if let result = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            
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
            serverServices.mprintln("Couldn't retrieve post actions")
        }
        
        serverServices.hideMessages()
        return post
    }
    
    
    func getUserPath() -> String? {
        if (!areServicesAvailable()) {
            return serverServices.readStringFromFile("userPath.txt")
        }
        serverServices.mprintln("Retrieving current user path...")
        
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.userPathUrl(), fileName: "userPath.txt")
        
        if let data = dataVal {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            serverServices.hideMessages()
            return ServerServices.condenseWhitespace(datastring! as String)
        } else {
            serverServices.mprintln("Coudln't retrieve current user path")
        }
        serverServices.hideMessages()
        return nil;
    }
    
    func getWorkflowTasks() -> [Task] {
        var taskArray = [Task]()
        var dataVal : NSData?
        var online : Bool = false
        if (!areServicesAvailable()) {
            serverServices.mprintln("Probably offline, retrieving workflow tasks from local cache...")
            dataVal = serverServices.readDataFromFile("workflow-tasks.json")
        } else {
            serverServices.mprintln("Retrieving workflow tasks...")
            let jahiaWorkflowTasksURL : NSURL = NSURL(string: jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(jahiaServerSettings.jahiaUserPath)/workflowTasks?includeFullChildren&resolveReferences")!
            
            (dataVal,online) = serverServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(jahiaServerSettings.jahiaUserPath)/workflowTasks?includeFullChildren&resolveReferences", fileName:"workflow-tasks.json")
        }
        
        if let data = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            
            let workflowTasksChildren = jsonResult["children"] as! NSDictionary
            
            let workflowTaskChildrenDict = workflowTasksChildren as! [String:NSDictionary]
            
            for (key,value) in workflowTaskChildrenDict {
                let task = Task(taskName: key, fromNSDictionary: value)
                if (task.state != "Finished") {
                    taskArray.append(task)
                }
            }
        } else {
            serverServices.mprintln("Couldn't retrieve workflow tasks")
        }
        serverServices.hideMessages()
        return taskArray
    }
    
    func refreshTask(task : Task) -> Task? {
        if (!areServicesAvailable()) {
            return task
        }
        
        serverServices.mprintln("Refreshing task \(task.path) ...")
        
        var error : NSError?
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(task.path!)?includeFullChildren&resolveReferences")
        if let result = dataVal {
            serverServices.writeDataToFile("task-\(task.identifier).json", data: dataVal!)
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            
            serverServices.hideMessages()
            return Task(taskName: task.name!, fromNSDictionary: jsonResult)
        } else {
            serverServices.mprintln("Couldn't retrieve task")
        }
        serverServices.hideMessages()
        return nil
    }
    
    func getTaskActions(task : Task) -> Task {
        if (!areServicesAvailable()) {
            return task
        }
        serverServices.mprintln("Retrieving task actions...")
        
        let jahiaTaskActionsURL : NSURL = NSURL(string: jahiaServerSettings.taskActionsUrl(task.path!))!
        
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/default/en/paths\(task.path!)?includeFullChildren&resolveReferences")
        if let result = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error : NSError?
            let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            
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
            serverServices.mprintln("Couldn't retrieve task actions")
        }
        
        serverServices.hideMessages()
        return task
    }
    
    func performTaskAction(task: Task, actionName : String, finalOutcome : String?) -> Bool {
        var result = false
        serverServices.mprintln("Sending task action \(actionName) with outcome \(finalOutcome) to Jahia server...")
        
        let requestString : String = "action=\(actionName)" + ((finalOutcome != nil) ? "&finalOutcome=\(finalOutcome!)" : "");
        let (dataVal,online) = serverServices.httpRequest(jahiaServerSettings.taskActionsUrl(task.path!), body: requestString)
        if let dataResult = dataVal {
            serverServices.mprintln("Action sent successfully.")
            result = true
        } else {
            serverServices.mprintln("Action sending failed")
        }
        serverServices.hideMessages()
        return result
    }
    
    func getLatestPosts() -> [Post] {
        var posts = [Post]()
        serverServices.mprintln("Retrieving latest posts...")
        
        var jsonQueryReply : [NSDictionary]?
        var online = false
        
        if (jahiaServerSettings.jahiaUsePreparedQueries) {
            serverServices.mprintln("Using prepary queries...")
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
            serverServices.mprintln("Couldn't retrieve latest posts!")
        }
        serverServices.hideMessages()
        return posts
        
    }
    
    func refreshPost(post : Post) -> Post? {
        if (!areServicesAvailable()) {
            return post
        }
        serverServices.mprintln("Refreshing post \(post.path!) ...")
        
        let (dataVal,online) = serverServices.httpGet(jahiaServerSettings.jcrApiUrl() + "/live/en/paths\(post.path!)?includeFullChildren&resolveReferences")
        if let result = dataVal {
            // let datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            
            serverServices.hideMessages()
            return Post(fromNSDictionary: jsonResult)
        } else {
            serverServices.mprintln("Couldn't retrieve update for post \(post.path)")
        }
        serverServices.hideMessages()
        return nil
        
    }
    
    func replyToPost(post : Post, title : String?, body : String?) -> Post? {
        if (!areServicesAvailable()) {
            return post
        }
        serverServices.mprintln("Replying to post \(post.path!) ...")
        
        let regex = try! NSRegularExpression(
            pattern: "[^0-9a-zA-Z]",
            options: NSRegularExpressionOptions.CaseInsensitive)
        
        let range = NSMakeRange(0, (title!).characters.count)
        let newNodeName : String = regex.stringByReplacingMatchesInString(title!,
            options: NSMatchingOptions(),
            range:range ,
            withTemplate: "")
        
        let requestString : String = "{\"type\" : \"jnt:post\", \"properties\": { \"jcr:title\" : { \"value\" : \"\(serverServices.jsonEscaping(title!))\" }, \"content\" : { \"value\" : \"\(serverServices.jsonEscaping(body!))\" } } }";
        serverServices.mprintln("payload=\(requestString)")
        let (dataVal,online) = serverServices.httpRequest(jahiaServerSettings.contextUrl() + "/modules" + post.parentUri! + "/children/" + newNodeName, body: requestString, contentType : "application/json", expectedSuccessCode: 201, httpMethod: "PUT")
        if let dataResult = dataVal {
            var datastring = NSString(data: dataVal!, encoding: NSUTF8StringEncoding)
            var error: NSError?
            let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            
            serverServices.hideMessages()
            return Post(fromNSDictionary: jsonResult)
        } else {
            serverServices.mprintln("Couldn't retrieve update for post \(post.path)")
        }
        serverServices.hideMessages()
        return nil
    }

    
    func logout() {
        
    }
}