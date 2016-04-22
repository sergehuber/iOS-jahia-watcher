//
//  CXSSettingsViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 09.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class CXSSettingsViewController: UIViewController {

    let contextServerSettings : ContextServerSettings = ContextServerSettings.sharedInstance
    let serverServices : ServerServices = ServerServices.sharedInstance
    
    @IBOutlet weak var protocolTextField: UITextField!
    @IBOutlet weak var hostnameTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var contextPathTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        protocolTextField.text = contextServerSettings.contextServerProtocol
        hostnameTextField.text = contextServerSettings.contextServerHost
        portTextField.text = String(contextServerSettings.contextServerPort)
        contextPathTextField.text = contextServerSettings.contextServerContextPath
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissKeyboard")
        let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        let toolbarItems = [ doneBarButton ]
        keyboardToolbar.setItems(toolbarItems, animated: false)
        
        protocolTextField.inputAccessoryView = keyboardToolbar
        hostnameTextField.inputAccessoryView = keyboardToolbar
        portTextField.inputAccessoryView = keyboardToolbar
        contextPathTextField.inputAccessoryView = keyboardToolbar
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func saveSettings(sender: AnyObject) {
        contextServerSettings.contextServerProtocol = protocolTextField.text!
        contextServerSettings.contextServerHost = hostnameTextField.text!
        contextServerSettings.contextServerPort = Int(portTextField.text!)!
        contextServerSettings.contextServerContextPath = contextPathTextField.text!
        contextServerSettings.save()
        
        let contextServerSession = ContextServerSession()
        contextServerSession.attemptedLogin = false
        if (!contextServerSession.areServicesAvailable()) {
            let alertController = UIAlertController(title: "CXS Connection error", message: "Connection to Context Server failed.",preferredStyle: UIAlertControllerStyle.Alert)
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
        contextServerSettings.load()
        protocolTextField.text = contextServerSettings.contextServerProtocol
        hostnameTextField.text = contextServerSettings.contextServerHost
        portTextField.text = String(contextServerSettings.contextServerPort)
        contextPathTextField.text = contextServerSettings.contextServerContextPath
    }
    
    @IBAction func endEditingProtocol(sender: AnyObject) {
        protocolTextField.resignFirstResponder()
    }
    
    @IBAction func endEditingHostName(sender: AnyObject) {
        hostnameTextField.resignFirstResponder()
    }

}
