//
//  SettingsViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    let jahiaServerSettings : JahiaServerSettings = JahiaServerSettings.sharedInstance
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
        protocolTextField.text = jahiaServerSettings.jahiaServerProtocol
        hostnameTextField.text = jahiaServerSettings.jahiaServerHost
        portTextField.text = String(jahiaServerSettings.jahiaServerPort)
        contextPathTextField.text = jahiaServerSettings.jahiaServerContextPath
        userNameTextField.text = jahiaServerSettings.jahiaUserName
        passwordTextField.text = jahiaServerSettings.jahiaPassword
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissKeyboard")
        let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        let toolbarItems = [ doneBarButton ]
        keyboardToolbar.setItems(toolbarItems, animated: false)
        
        protocolTextField.inputAccessoryView = keyboardToolbar
        hostnameTextField.inputAccessoryView = keyboardToolbar
        portTextField.inputAccessoryView = keyboardToolbar
        contextPathTextField.inputAccessoryView = keyboardToolbar
        userNameTextField.inputAccessoryView = keyboardToolbar
        passwordTextField.inputAccessoryView = keyboardToolbar
        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }    
    
    @IBAction func saveSettings(sender: AnyObject) {
        jahiaServerSettings.jahiaServerProtocol = protocolTextField.text
        jahiaServerSettings.jahiaServerHost = hostnameTextField.text
        jahiaServerSettings.jahiaServerPort = portTextField.text.toInt()!
        jahiaServerSettings.jahiaServerContextPath = contextPathTextField.text
        jahiaServerSettings.jahiaUserName = userNameTextField.text
        jahiaServerSettings.jahiaPassword = passwordTextField.text
        jahiaServerSettings.save()
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
        jahiaServerSettings.load()
        protocolTextField.text = jahiaServerSettings.jahiaServerProtocol
        hostnameTextField.text = jahiaServerSettings.jahiaServerHost
        portTextField.text = String(jahiaServerSettings.jahiaServerPort)
        contextPathTextField.text = jahiaServerSettings.jahiaServerContextPath
        userNameTextField.text = jahiaServerSettings.jahiaUserName
        passwordTextField.text = jahiaServerSettings.jahiaPassword
    }
    
    @IBAction func endEditingProtocol(sender: AnyObject) {
        protocolTextField.resignFirstResponder()
    }
    
    @IBAction func endEditingHostName(sender: AnyObject) {
        hostnameTextField.resignFirstResponder()
    }

}