//
//  AppDelegate.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 09.03.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let serverServices : ServerServices = ServerServices.sharedInstance
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!, identifier: "Ejfp")

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("didFinishLaunchingWithOptions")
        // Override point for customization after application launch.
        
        // other setup tasks here....
        registerSettingsAndCategories()
        
        application.registerForRemoteNotifications();
        
        ServerServices.messageDelegate = SwiftSpinnerMessageDelegate()
        
        locationManager.delegate = self;
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeaconsInRegion(region)
        
        let contextServerSession : ContextServerSession = ContextServerSession()
        if (contextServerSession.areServicesAvailable()) {
            let startupEvent = CXSEvent()
            startupEvent.eventType = "MobileAppStart"
            startupEvent.profileId = contextServerSession.currentContext!.profileId
            startupEvent.sessionId = contextServerSession.currentContext!.sessionId
            startupEvent.source = CXSItem(itemType: "mobileApp", itemId: "JahiaWatcherApp")
            startupEvent.target = CXSItem(itemType: "mobileApp", itemId: "JahiaWatcherApp")
            startupEvent.scope = "ACME-SPACE"
            
            var eventCollectorRequest = CXSEventCollectorRequest()
            
            eventCollectorRequest.events.append(startupEvent)
            
            contextServerSession.sendEvents(eventCollectorRequest, sessionId: contextServerSession.currentContext!.sessionId!)
        }
        
        return true
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity == CLProximity.Immediate }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
            let contextServerSession : ContextServerSession = ContextServerSession()
            if (contextServerSession.areServicesAvailable()) {
                var eventCollectorRequest = CXSEventCollectorRequest()
                
                for beacon in knownBeacons {

                let beaconEvent = CXSEvent()
                beaconEvent.eventType = "EnterBeaconRegion"
                beaconEvent.profileId = contextServerSession.currentContext!.profileId
                beaconEvent.sessionId = contextServerSession.currentContext!.sessionId
                beaconEvent.source = CXSItem(itemType: "mobileApp", itemId: "JahiaWatcherApp")
                beaconEvent.target = CXSItem(itemType: "mobileBean", itemId: "\(beacon.major).\(beacon.minor)")
                beaconEvent.scope = "ACME-SPACE"
            
                eventCollectorRequest.events.append(beaconEvent)
                }
                
                contextServerSession.sendEvents(eventCollectorRequest, sessionId: contextServerSession.currentContext!.sessionId!)
            }
        }
        print("didRangeBeacons: \(beacons)")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion: \(region)")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion: \(region)")
    }
    
    func registerSettingsAndCategories() {
        
        let viewPostAction = UIMutableUserNotificationAction()
        viewPostAction.title = NSLocalizedString("View", comment: "View post")
        viewPostAction.identifier = "viewPostAction"
        viewPostAction.activationMode = UIUserNotificationActivationMode.Foreground
        viewPostAction.authenticationRequired = false
        
        let newPostCategory = UIMutableUserNotificationCategory()
        newPostCategory.setActions([viewPostAction],
        forContext: UIUserNotificationActionContext.Default)
        newPostCategory.identifier = "newPost"
        
        // Configure other actions and categories and add them to the set...

        let viewTaskAction = UIMutableUserNotificationAction()
        viewTaskAction.title = NSLocalizedString("View", comment: "View task")
        viewTaskAction.identifier = "viewTaskAction"
        viewTaskAction.activationMode = UIUserNotificationActivationMode.Foreground
        viewTaskAction.authenticationRequired = false
        
        let newTaskCategory = UIMutableUserNotificationCategory()
        newTaskCategory.setActions([viewTaskAction],
            forContext: UIUserNotificationActionContext.Default)
        newTaskCategory.identifier = "newTask"
        
        let categoryArray : [UIUserNotificationCategory] = [newPostCategory, newTaskCategory]
        
        let categories = Set<UIUserNotificationCategory>(categoryArray)
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories)
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
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]?) -> Void)) {
        let action = userInfo!["action"] as! String
        print("handleWatchKitExtensionRequest with action \(action)")
        var replyMap = [NSObject:AnyObject]()
        if action == "previewTaskChanges" {
            let previewUrl = userInfo!["previewUrl"] as! String
            let previewNSURL = NSURL(string:previewUrl)!
            let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
            if (scheduledLocalNotifications!.count > 0) {
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }
            let localNotification = UILocalNotification()
            localNotification.userInfo = userInfo
            if #available(iOS 8.2, *) {
                localNotification.alertTitle = "Preview task"
            } else {
                // Fallback on earlier versions
            }
            localNotification.alertBody = "This task will open on the iPhone"
            localNotification.fireDate = NSDate()
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
            if UIApplication.sharedApplication().canOpenURL(previewNSURL) {
                UIApplication.sharedApplication().openURL(previewNSURL)
                replyMap["actionPerformed"] = "Opened task changes preview URL \(previewUrl)"
            } else {
            }
        } else if (action == "viewPost") {
            let viewUrl = userInfo!["viewUrl"] as! String
            let viewNSURL = NSURL(string:viewUrl)!
            let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
            if (scheduledLocalNotifications!.count > 0) {
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }
            let localNotification = UILocalNotification()
            localNotification.userInfo = userInfo
            if #available(iOS 8.2, *) {
                localNotification.alertTitle = "View post"
            } else {
                // Fallback on earlier versions
            }
            localNotification.alertBody = "This post will open on the iPhone"
            localNotification.fireDate = NSDate()
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
            if (UIApplication.sharedApplication().canOpenURL(viewNSURL)) {
                UIApplication.sharedApplication().openURL(viewNSURL)
                replyMap["actionPerformed"] = "Opened post view URL \(viewUrl)"
            } else {
            }
        }
        reply(replyMap)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print("didRegisterUserNotificationSettings")
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("tokenString: \(tokenString)")
        print(deviceToken.description)

        let jahiaServerSession = JahiaServerSession()
        jahiaServerSession.registerDeviceToken(tokenString);
        
        let contextServerSession = ContextServerSession()
        contextServerSession.registerDeviceToken(tokenString);
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
    
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {

        print("didReceiveRemoteNotification with fetchCompletionHandler")
        if ( application.applicationState == UIApplicationState.Active ) {
            // app was already in the foreground
            print("Application was already active")
            displayNotificationAlert(userInfo)
        } else {
            // app was just brought from background to foreground
            print("Application was either in the background or not running")
            displayNotificationData(userInfo)
        }
        handler(UIBackgroundFetchResult.NewData)
    }
    
    func displayNotificationData(userInfo : [NSObject : AnyObject]) {
        let nodeIdentifier = userInfo["nodeIdentifier"] as! String
        let apsInfo = userInfo["aps"] as! [String:AnyObject]
        let alertTitle = apsInfo["alert"] as! String
        let category = apsInfo["category"] as! String
        NSNotificationCenter.defaultCenter().postNotificationName("pushNotification\(category)", object: nil, userInfo: userInfo)
    }
    
    func displayNotificationAlert(userInfo: [NSObject : AnyObject]) {
        let nodeIdentifier = userInfo["nodeIdentifier"] as! String
        let apsInfo = userInfo["aps"] as! [String:AnyObject]
        let alertTitle = apsInfo["alert"] as! String
        let category = apsInfo["category"] as! String
        var categoryTitle = "A new post was created"
        if (category == "newTask") {
            categoryTitle = "A new task was created"
        } else if (category == "newPost") {
        } else {
            print("Unknown category \(category) received!")
        }
        let alert = UIAlertController(title: categoryTitle, message: alertTitle, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "View", style: UIAlertActionStyle.Default, handler: {
            action in switch action.style{
            case .Default:
                print("View default")
                self.displayNotificationData(userInfo)
            case .Cancel:
                print("View cancel")
                
            case .Destructive:
                print("View destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: {
            action in switch action.style{
            case .Default:
                print("Dismiss default")
                
            case .Cancel:
                print("Dimiss cancel")
                
            case .Destructive:
                print("Dismiss destructive")
            }
        }))
        window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print("handleActionWithIdentifier identifier=\(identifier) for remote notification with completionHandler")
        displayNotificationAlert(userInfo)
        completionHandler()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("didReceiveRemoteNotification")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let userInfo = notification.userInfo
        let action = userInfo!["action"] as! String
        print("didReceiveLocationNotification with action \(action)")
        if action == "previewTaskChanges" {
            let previewUrl = userInfo!["previewUrl"] as! String
            let previewNSURL = NSURL(string:previewUrl)!
            if UIApplication.sharedApplication().canOpenURL(previewNSURL) {
                UIApplication.sharedApplication().openURL(previewNSURL)
            } else {
            }
        } else if (action == "viewPost") {
            let viewUrl = userInfo!["viewUrl"] as! String
            let viewNSURL = NSURL(string:viewUrl)!
            if (UIApplication.sharedApplication().canOpenURL(viewNSURL)) {
                UIApplication.sharedApplication().openURL(viewNSURL)
            } else {
            }
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        print("handleActionWithIdentifier for local notification with completionHandler")
        completionHandler()
    }
    
    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        if (userActivityType == "com.jahia.mobile.apps.Jahia-Watcher.watchkitapp.activities.viewPost" ||
            userActivityType == "com.jahia.mobile.apps.Jahia-Watcher.watchkitapp.activities.viewTask") {
                print("Authorizing activity type \(userActivityType)")
                return true
        }
        print("Received unrecognized activity type \(userActivityType)")
        return false
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        print("Ready to handle activity \(userActivity)")
        if (userActivity.activityType == "com.jahia.mobile.apps.Jahia-Watcher.watchkitapp.activities.viewPost") {
            displayNotificationData(userActivity.userInfo!)
        } else if (userActivity.activityType == "com.jahia.mobile.apps.Jahia-Watcher.watchkitapp.activities.viewTask") {
            displayNotificationData(userActivity.userInfo!)            
        } else {
            print("Received unrecognized activity type \(userActivity.activityType)")
            return false
        }
        return true
    }
}

