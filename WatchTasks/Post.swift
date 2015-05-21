//
//  Post.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 24.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

class Post {
        
    var identifier : String?
    var path : String?
    var title : String?
    var author : String?
    var date : NSDate?
    var spam : Bool?
    var content : String?
    var viewUrl : String?
    var actions : [PostAction]?
    var parentUri : String?
    
    init(fromNSDictionary : NSDictionary) {
        identifier = fromNSDictionary["id"] as? String
        path = fromNSDictionary["path"] as? String
        let mixins = fromNSDictionary["mixins"] as! NSDictionary
        if (mixins["jmix__spamFilteringSpamDetected"] != nil) {
            spam = true
        } else {
            spam = false
        }
        let postProperties : NSDictionary = fromNSDictionary["properties"] as! NSDictionary
        let titleProperty : NSDictionary = postProperties["jcr__title"] as! NSDictionary
        title = titleProperty["value"] as? String
        let contentProperty : NSDictionary? = postProperties["content"] as? NSDictionary
        let createdProperty  : NSDictionary? = postProperties["jcr__created"] as? NSDictionary
        let createdByProperty  : NSDictionary? = postProperties["jcr__createdBy"] as? NSDictionary
        if (contentProperty != nil) {
            var postContent : String = contentProperty!["value"] as! String
            content = JahiaServerServices.stripHTML(postContent)
        }
        if (createdProperty != nil) {
            let createdValue : NSNumber = createdProperty!["value"] as! NSNumber
            let postDateTimeInterval = NSTimeInterval(createdValue.longValue / 1000)
            date = NSDate(timeIntervalSince1970: postDateTimeInterval)
        }
        if (createdByProperty != nil) {
            author = createdByProperty!["value"] as? String
        }
        let postLinks = fromNSDictionary["_links"] as! [String:AnyObject]
        let postParentLink = postLinks["parent"] as! [String:String]
        parentUri = postParentLink["href"]
    }
}
