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
        if (!jahiaServerServices.areServicesAvailable()) {
            println("No existing settings found, presenting settings tab first")
            for viewController in viewControllers as! [UIViewController] {
                if viewController is SettingsViewController {
                    selectedViewController = viewController
                }
            }
        }
    }
}
