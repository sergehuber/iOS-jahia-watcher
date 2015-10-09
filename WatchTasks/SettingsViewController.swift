//
//  SettingsViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    let jahiaJahiaServerSettings : JahiaServerSettings = JahiaServerSettings.sharedInstance
    let serverServices : ServerServices = ServerServices.sharedInstance

    @IBOutlet weak var protocolTextField: UITextField!
    @IBOutlet weak var hostnameTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var contextPathTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        protocolTextField.text = jahiaJahiaServerSettings.jahiaServerProtocol
        hostnameTextField.text = jahiaJahiaServerSettings.jahiaServerHost
        portTextField.text = String(jahiaJahiaServerSettings.jahiaServerPort)
        contextPathTextField.text = jahiaJahiaServerSettings.jahiaServerContextPath
        userNameTextField.text = jahiaJahiaServerSettings.jahiaUserName
        passwordTextField.text = jahiaJahiaServerSettings.jahiaPassword
        
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
        jahiaJahiaServerSettings.jahiaServerProtocol = protocolTextField.text!
        jahiaJahiaServerSettings.jahiaServerHost = hostnameTextField.text!
        jahiaJahiaServerSettings.jahiaServerPort = Int(portTextField.text!)!
        jahiaJahiaServerSettings.jahiaServerContextPath = contextPathTextField.text!
        jahiaJahiaServerSettings.jahiaUserName = userNameTextField.text!
        jahiaJahiaServerSettings.jahiaPassword = passwordTextField.text!
        jahiaJahiaServerSettings.save()
        
        let jahiaServerSession = JahiaServerSession()
        jahiaServerSession.jcrApiVersionRequested = false
        jahiaServerSession.attemptedLogin = false
        if (!jahiaServerSession.areServicesAvailable()) {
            let alertController = UIAlertController(title: "Connection error", message: "Connection failed. ",preferredStyle: UIAlertControllerStyle.Alert)
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
        jahiaJahiaServerSettings.load()
        protocolTextField.text = jahiaJahiaServerSettings.jahiaServerProtocol
        hostnameTextField.text = jahiaJahiaServerSettings.jahiaServerHost
        portTextField.text = String(jahiaJahiaServerSettings.jahiaServerPort)
        contextPathTextField.text = jahiaJahiaServerSettings.jahiaServerContextPath
        userNameTextField.text = jahiaJahiaServerSettings.jahiaUserName
        passwordTextField.text = jahiaJahiaServerSettings.jahiaPassword
    }
    
    @IBAction func endEditingProtocol(sender: AnyObject) {
        protocolTextField.resignFirstResponder()
    }
    
    @IBAction func endEditingHostName(sender: AnyObject) {
        hostnameTextField.resignFirstResponder()
    }

}