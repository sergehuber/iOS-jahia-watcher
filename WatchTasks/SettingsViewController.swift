//
//  SettingsViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    let jahiaWatcherSettings : JahiaWatcherSettings = JahiaWatcherSettings.sharedInstance
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance

    @IBOutlet weak var protocolTextField: UITextField!
    @IBOutlet weak var hostnameTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var contextPathTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        protocolTextField.text = jahiaWatcherSettings.jahiaServerProtocol
        hostnameTextField.text = jahiaWatcherSettings.jahiaServerHost
        portTextField.text = String(jahiaWatcherSettings.jahiaServerPort)
        contextPathTextField.text = jahiaWatcherSettings.jahiaServerContextPath
        userNameTextField.text = jahiaWatcherSettings.jahiaUserName
        passwordTextField.text = jahiaWatcherSettings.jahiaPassword
    }
    
    @IBAction func saveSettings(sender: AnyObject) {
        jahiaWatcherSettings.jahiaServerProtocol = protocolTextField.text
        jahiaWatcherSettings.jahiaServerHost = hostnameTextField.text
        jahiaWatcherSettings.jahiaServerPort = portTextField.text.toInt()!
        jahiaWatcherSettings.jahiaServerContextPath = contextPathTextField.text
        jahiaWatcherSettings.jahiaUserName = userNameTextField.text
        jahiaWatcherSettings.jahiaPassword = passwordTextField.text
        jahiaWatcherSettings.save()
        jahiaServerServices.attemptedLogin = false
        if (!jahiaServerServices.login()) {
            let alertController = UIAlertController(title: "Login error", message: "Login failed. ",preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { action in
                // do nothing
            }))
            self.presentViewController(alertController, animated: true) {
                
            }
        }
        if self.parentViewController is MainTabBarController {
            let mainTabBarController = self.parentViewController as! MainTabBarController
            mainTabBarController.displayPosts()
        }
    }

    @IBAction func reloadSettings(sender: AnyObject) {
        jahiaWatcherSettings.load()
        protocolTextField.text = jahiaWatcherSettings.jahiaServerProtocol
        hostnameTextField.text = jahiaWatcherSettings.jahiaServerHost
        portTextField.text = String(jahiaWatcherSettings.jahiaServerPort)
        contextPathTextField.text = jahiaWatcherSettings.jahiaServerContextPath
        userNameTextField.text = jahiaWatcherSettings.jahiaUserName
        passwordTextField.text = jahiaWatcherSettings.jahiaPassword
    }
    
    @IBAction func endEditingProtocol(sender: AnyObject) {
        protocolTextField.resignFirstResponder()
    }
    
    @IBAction func endEditingHostName(sender: AnyObject) {
        hostnameTextField.resignFirstResponder()
    }

}