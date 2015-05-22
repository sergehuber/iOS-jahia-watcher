//
//  MainTabBarController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 11.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTaskNotificationReceived:", name: "pushNotificationnewTask", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newPostNotificationReceived:", name: "pushNotificationnewPost", object: nil)

        if (!jahiaServerServices.areServicesAvailable()) {
            println("No existing settings found, presenting settings tab first")
            displaySettings()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func displaySettings() {
        for viewController in viewControllers as! [UIViewController] {
            if viewController is SettingsViewController {
                selectedViewController = viewController
            }
        }
    }
    
    func displayPosts() {
        for viewController in viewControllers as! [UIViewController] {
            if viewController.restorationIdentifier == "PostsNavigationController" {
                selectedViewController = viewController
            }
        }
    }

    func displaySpecificPost(postIdentifier : String) {
        for viewController in viewControllers as! [UIViewController] {
            if viewController.restorationIdentifier == "PostsNavigationController" {
                selectedViewController = viewController
                let postsNavigationController = viewController as! UINavigationController
                if ((!(postsNavigationController.topViewController is PostsTableViewController))) {
                    postsNavigationController.popToRootViewControllerAnimated(true)
                }
                let postsTableViewController = postsNavigationController.topViewController as! PostsTableViewController
                postsTableViewController.displaySpecificPost(postIdentifier)
            }
        }
    }
    
    func displayTasks() {
        for viewController in viewControllers as! [UIViewController] {
            if viewController.restorationIdentifier == "TasksNavigationController" {
                selectedViewController = viewController
            }
        }
    }
    
    func displaySpecificTask(taskIdentifier : String) {
        for viewController in viewControllers as! [UIViewController] {
            if viewController.restorationIdentifier == "TasksNavigationController" {
                selectedViewController = viewController
                let tasksNavigationController = viewController as! UINavigationController
                if ((!(tasksNavigationController.topViewController is TasksTableViewController))) {
                    tasksNavigationController.popToRootViewControllerAnimated(true)
                }
                let tasksTableViewController = tasksNavigationController.topViewController as! TasksTableViewController
                tasksTableViewController.displaySpecificTask(taskIdentifier)
            }
        }
    }
    
    func newTaskNotificationReceived(notification : NSNotification) {
        let userInfo = notification.userInfo
        let nodeIdentifier = userInfo!["nodeIdentifier"] as! String
        displaySpecificTask(nodeIdentifier)
    }

    func newPostNotificationReceived(notification : NSNotification) {
        let userInfo = notification.userInfo
        let nodeIdentifier = userInfo!["nodeIdentifier"] as! String
        displaySpecificPost(nodeIdentifier)
    }
    
}
