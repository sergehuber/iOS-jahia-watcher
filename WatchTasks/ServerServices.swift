//
//  ServerServices.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class ServerServices : NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {

    static var messageDelegate : MessageDelegate?
    var nsURLSession : NSURLSession? = nil
    
    class var sharedInstance: ServerServices {
        struct Static {
            static let instance: ServerServices = ServerServices()
        }
        return Static.instance
    }
    
    class func mprintln(message : String) {
        messageDelegate?.displayMessage(message)
    }
    
    class func hideMessages() {
        messageDelegate?.hideAllMessages()
    }
    
    override init() {
        super.init()
        let nsURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        nsURLSession = NSURLSession(configuration: nsURLSessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod.compare(NSURLAuthenticationMethodServerTrust) == .OrderedSame {
            print(challenge.protectionSpace)
            // for the moment they both do the same thing but we leave the code to make it more secure later
            if challenge.protectionSpace.host.compare("HOST_NAME") == .OrderedSame {
                completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
            } else {
                completionHandler(.UseCredential, NSURLCredential(trust: challenge.protectionSpace.serverTrust!))
            }
            
        } else if challenge.protectionSpace.authenticationMethod.compare(NSURLAuthenticationMethodHTTPBasic) == .OrderedSame {
            if challenge.previousFailureCount > 0 {
                print("Alert Please check the credential")
                completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge, nil)
            } else {
                let credential = NSURLCredential(user:"karaf", password:"karaf", persistence: .ForSession)
                completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,credential)
            }
        } else {
            completionHandler(.UseCredential, NSURLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        print("task-didReceiveChallenge")
        
        if challenge.previousFailureCount > 0 {
            print("Alert Please check the credential")
            completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge, nil)
        } else {
            var credential = NSURLCredential(user:"karaf", password:"karaf", persistence: .ForSession)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,credential)
        }
        
        
    }
    
    /*
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        mprintln("didReceiveChallenge protectionSpace=\(challenge.protectionSpace) serverTrust=\(challenge.protectionSpace.serverTrust!) proposedCredentials=\(challenge.proposedCredential)")
        completionHandler(.UseCredential, NSURLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    */
    
    func mprintln(message : String) {
        ServerServices.mprintln(message)
    }
    
    func hideMessages() {
        ServerServices.hideMessages()
    }
    
    func writeDataToFile(filePath : String?, data : NSData) -> Bool {
        if (filePath == nil) {
            return false
        }
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) 
        let documentDirectory = paths[0]
        let fullFilePath = (documentDirectory as NSString).stringByAppendingPathComponent(filePath!)
        data.writeToFile(fullFilePath, atomically: true)
        return true
    }
    
    func readDataFromFile(filePath : String?) -> NSData? {
        if (filePath == nil) {
            return nil
        }
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) 
        let documentDirectory = paths[0]
        let fullFilePath = (documentDirectory as NSString).stringByAppendingPathComponent(filePath!)
        let data = NSData(contentsOfFile: fullFilePath)
        return data
    }
    
    func readJSONFromFile(filePath : String?) -> AnyObject? {
        if (filePath == nil) {
            return nil
        }
        let data = readDataFromFile(filePath)
        if let dataVal = data {
            let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            return jsonResult
        }
        return nil
    }

    func readStringFromFile(filePath : String?, encoding:UInt = NSUTF8StringEncoding) -> String? {
        if (filePath == nil) {
            return nil
        }
        let data = readDataFromFile(filePath)
        if let dataVal = data {
            let dataString = NSString(data: dataVal, encoding: encoding)
            return dataString as? String
        }
        return nil
    }

    func httpGet(url : String, fileName : String? = nil, expectedSuccessCode : Int = 200, timeoutInterval : NSTimeInterval = 10) -> (NSData?,Bool) {
        let getURL : NSURL = NSURL(string: url)!
        
        let request = NSMutableURLRequest(URL: getURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeoutInterval
        
        var responseCode = -1
        var dataVal : NSData?
        let dispatchGroup = dispatch_group_create()
        dispatch_group_enter(dispatchGroup)
        nsURLSession!.dataTaskWithRequest(request, completionHandler: {(data, response, _) in
            if let httpResponse = response as? NSHTTPURLResponse {
                responseCode = httpResponse.statusCode
                dataVal = data
            }
            dispatch_group_leave(dispatchGroup)
        }).resume()
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
        
            if (responseCode == expectedSuccessCode) {
                writeDataToFile(fileName, data: dataVal!)
                return (dataVal,true)
            } else {
                dataVal = readDataFromFile(fileName)
                return (dataVal,false)
            }
    }
    
    func httpRequest(url : String, body : String? = nil, fileName : String? = nil, contentType : String? = nil, expectedSuccessCode : Int = 200, timeoutInterval : NSTimeInterval = 10, httpMethod : String = "POST") -> (NSData?,Bool) {
        let postURL : NSURL = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: postURL)
        
        request.HTTPMethod = httpMethod
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        if (contentType != nil) {
            request.addValue(contentType!, forHTTPHeaderField: "Content-Type")
        } else {
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        request.timeoutInterval = timeoutInterval
        if (body != nil) {
            let postData = NSMutableData()
            postData.appendData(body!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            request.setValue(NSString(format: "%lu", postData.length) as String, forHTTPHeaderField: "Content-Length")
            request.HTTPBody = postData
        }
        
        var responseCode = -1
        var dataVal : NSData?
        let dispatchGroup = dispatch_group_create()
        dispatch_group_enter(dispatchGroup)
        nsURLSession!.dataTaskWithRequest(request, completionHandler: {(data, response, _) in
            if let httpResponse = response as? NSHTTPURLResponse {
                responseCode = httpResponse.statusCode
                dataVal = data
            }
            dispatch_group_leave(dispatchGroup)
        }).resume()
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
        
            if (responseCode == expectedSuccessCode) {
                mprintln("\(request.HTTPMethod) request to url \(request.URL!) successful.")
                writeDataToFile(fileName, data: dataVal!)
                return (dataVal,true)
            } else {
                mprintln("Error during \(request.HTTPMethod) request to url \(request.URL) !")
                dataVal = readDataFromFile(fileName)
                return (dataVal,false)
            }
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
        
        let re = try! NSRegularExpression(pattern: regex, options: [])
        let matches = re.matchesInString(text, options: [], range: NSMakeRange(0, text.characters.count))
        
        var result = [String]()
        
        for match in matches {
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
            result!.replaceRange(realInput.startIndex...realInput.startIndex, with: String(realInput[realInput.startIndex]).capitalizedString)
        }
        return result
    }
    
    class func condenseWhitespace(string: String) -> String {
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.characters.isEmpty})
        return components.joinWithSeparator(" ")
    }
    
}