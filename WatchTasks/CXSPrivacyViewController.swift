//
//  CXSPrivacyViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 14.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class CXSPrivacyViewController: UIViewController {
    
    let contextServerSettings : ContextServerSettings = ContextServerSettings.sharedInstance

    @IBOutlet weak var profileIdTextField: UITextField!
    @IBOutlet weak var sessionIdTextField: UITextField!
    @IBOutlet weak var segmentsTextField: UITextField!
    @IBOutlet weak var interestsTextView: UITextView!
    var refreshTimer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        refreshData()
    }
    
    @IBAction func deleteProfile(sender: AnyObject) {
    }
    
    @IBAction func privateBrowsing(sender: AnyObject) {
    }
    
    @IBAction func Anonymize(sender: AnyObject) {
    }
    
    func refreshData() {
        let contextServerSession : ContextServerSession = ContextServerSession()
        contextServerSession.contextRequested=false
        if (contextServerSession.areServicesAvailable()) {
            let cxsContext = contextServerSession.currentContext
            profileIdTextField.text = cxsContext?.profileId
            sessionIdTextField.text = cxsContext?.sessionId
            if let segments = cxsContext?.profileSegments {
                var segmentText = ""
                for segment in segments {
                    segmentText += segment
                }
                segmentsTextField.text = segmentText
            }
            if let interests = cxsContext?.profileProperties?["interests"] as? [String:Int] {
                var interestsText = ""
                for (interestName,interestCount) in interests {
                    interestsText += interestName + " (" + String(interestCount) + ")\n"
                }
                interestsTextView.text = interestsText
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshData", userInfo: nil, repeats: true)
    }// Called when the view has been fully transitioned onto the screen. Default does nothing

    override func viewWillDisappear(animated: Bool) {
        refreshTimer?.invalidate()
    }// Called when the view is dismissed, covered or otherwise hidden. Default does nothing


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
