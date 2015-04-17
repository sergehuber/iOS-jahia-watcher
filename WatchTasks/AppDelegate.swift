//
//  AppDelegate.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 09.03.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        println("didFinishLaunchingWithOptions")
        // Override point for customization after application launch.
        
        // other setup tasks here....
        registerSettingsAndCategories()
        
        application.registerForRemoteNotifications();
        
        jahiaServerServices.login()
        
        return true
    }
    
    func registerSettingsAndCategories() {
        var categories = NSMutableSet()
        
        var viewPostAction = UIMutableUserNotificationAction()
        viewPostAction.title = NSLocalizedString("View", comment: "View post")
        viewPostAction.identifier = "viewPostAction"
        viewPostAction.activationMode = UIUserNotificationActivationMode.Foreground
        viewPostAction.authenticationRequired = false
        
        var markPostAsSpamAction = UIMutableUserNotificationAction()
        markPostAsSpamAction.title = NSLocalizedString("Mark as spam", comment: "Mark the current post as spam")
        markPostAsSpamAction.identifier = "markPostAsSpamAction"
        markPostAsSpamAction.activationMode = UIUserNotificationActivationMode.Foreground
        markPostAsSpamAction.authenticationRequired = true

        var deletePostAction = UIMutableUserNotificationAction()
        deletePostAction.title = NSLocalizedString("Delete", comment: "Delete the current post")
        deletePostAction.identifier = "deletePostAction"
        deletePostAction.activationMode = UIUserNotificationActivationMode.Foreground
        deletePostAction.authenticationRequired = true

        var blockUserAction = UIMutableUserNotificationAction()
        blockUserAction.title = NSLocalizedString("Block user", comment: "Block the post user")
        blockUserAction.identifier = "blockUserAction"
        blockUserAction.activationMode = UIUserNotificationActivationMode.Foreground
        blockUserAction.authenticationRequired = true
        
        var newPostCategory = UIMutableUserNotificationCategory()
        newPostCategory.setActions([viewPostAction, markPostAsSpamAction, deletePostAction, blockUserAction],
        forContext: UIUserNotificationActionContext.Default)
        newPostCategory.identifier = "newPost"
        categories.addObject(newPostCategory)
        
        // Configure other actions and categories and add them to the set...

        var viewTaskAction = UIMutableUserNotificationAction()
        viewTaskAction.title = NSLocalizedString("View", comment: "View task")
        viewTaskAction.identifier = "viewTaskAction"
        viewTaskAction.activationMode = UIUserNotificationActivationMode.Foreground
        viewTaskAction.authenticationRequired = false
        
        var viewTaskOnPhoneAction = UIMutableUserNotificationAction()
        viewTaskOnPhoneAction.title = NSLocalizedString("View on Phone", comment: "View the task on the phone")
        viewTaskOnPhoneAction.identifier = "viewTaskOnPhoneAction"
        viewTaskOnPhoneAction.activationMode = UIUserNotificationActivationMode.Foreground
        viewTaskOnPhoneAction.authenticationRequired = false

        var newTaskCategory = UIMutableUserNotificationCategory()
        newTaskCategory.setActions([viewTaskAction, viewTaskOnPhoneAction],
            forContext: UIUserNotificationActionContext.Default)
        newTaskCategory.identifier = "newTask"
        categories.addObject(newTaskCategory)
        
        var settings = UIUserNotificationSettings(forTypes: (.Alert | .Badge | .Sound),
            categories: categories as Set<NSObject>)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://localhost:8080/cms/dashboard/default/en/users/root.projects.html")!)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        println("didRegisterUserNotificationSettings")
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("didRegisterForRemoteNotificationsWithDeviceToken")
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        println("tokenString: \(tokenString)")
        println(deviceToken.description)
        jahiaServerServices.registerDeviceToken(tokenString);
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
    
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {

        println("didReceiveRemoteNotification")
        displayNotificationAlert(userInfo)
        handler(UIBackgroundFetchResult.NewData)
    }
    
    func displayNotificationAlert(userInfo: [NSObject : AnyObject]) {
        let nodeIdentifier = userInfo["nodeIdentifier"] as! String
        let apsInfo = userInfo["aps"] as! [String:AnyObject]
        let alertTitle = apsInfo["alert"] as! String
        let category = apsInfo["category"] as! String
        var categoryTitle = "A new post was created"
        if (category == "newTask") {
            categoryTitle = "A new task was created"
        }
        var alert = UIAlertController(title: categoryTitle, message: alertTitle, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "View", style: UIAlertActionStyle.Default, handler: {
            action in switch action.style{
            case .Default:
                println("View default")
                
            case .Cancel:
                println("View cancel")
                
            case .Destructive:
                println("View destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: {
            action in switch action.style{
            case .Default:
                println("Dismiss default")
                
            case .Cancel:
                println("Dimiss cancel")
                
            case .Destructive:
                println("Dismiss destructive")
            }
        }))
        window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        println("handleActionWithIdentifier identifier=\(identifier) for remote notification")
        displayNotificationAlert(userInfo)
        completionHandler()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("didReceiveRemoteNotification")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        println("didReceiveLocalNotification")
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        println("handleActionWithIdentifier for local notification")
        completionHandler()
    }
}

