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

    func readStringFromFile(filePath : String?, encoding:UInt = NSUTF8StringEncoding) -> String? {
        if (filePath == nil) {
            return nil
        }
        let data = readDataFromFile(filePath)
        if let dataVal = data {
            var dataString = NSString(data: data!, encoding: encoding)
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
                
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode == expectedSuccessCode) {
                writeDataToFile(fileName, data: dataVal!)
                return (dataVal,true)
            } else {
                dataVal = readDataFromFile(fileName)
                return (dataVal,false)
            }
        } else {
            mprintln("Couldn't retrieve data from url \(request.URL)")
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
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode == expectedSuccessCode) {
                mprintln("Post to url \(request.URL) successful.")
                writeDataToFile(fileName, data: dataVal!)
                return (dataVal,true)
            } else {
                mprintln("Error during post request to url \(request.URL) !")
                dataVal = readDataFromFile(fileName)
                return (dataVal,false)
            }
        } else {
            mprintln("Post failed")
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