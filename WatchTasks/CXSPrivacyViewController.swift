//
//  CXSPrivacyViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 14.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import UIKit
import Charts

class CXSPrivacyViewController: UIViewController {
    
    let contextServerSettings : ContextServerSettings = ContextServerSettings.sharedInstance

    @IBOutlet weak var profileIdTextField: UITextField!
    @IBOutlet weak var sessionIdTextField: UITextField!
    @IBOutlet weak var segmentsTextField: UITextField!
    @IBOutlet weak var interestsTextView: UITextView!
    @IBOutlet weak var interestsRadarChartView: RadarChartView!
    
    var refreshTimer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interestsRadarChartView.descriptionText = ""
        interestsRadarChartView.webLineWidth = 0.75
        interestsRadarChartView.innerWebLineWidth = 0.375
        interestsRadarChartView.webAlpha = 1.0;
        interestsRadarChartView.skipWebLineCount = 1
        
        let xAxis = interestsRadarChartView.xAxis
        xAxis.labelFont = UIFont(name: "HelveticaNeue-Light",size: 5.0)!
        
        let yAxis = interestsRadarChartView.yAxis;
        yAxis.labelFont = UIFont(name: "HelveticaNeue-Light",size: 5.0)!
        yAxis.labelCount = 6;
        yAxis.startAtZeroEnabled = true;
        
        let l = interestsRadarChartView.legend;
        l.position = .RightOfChart;
        l.font = UIFont(name: "HelveticaNeue-Light",size: 7.0)!
        l.xEntrySpace = 7.0;
        l.yEntrySpace = 5.0;
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
                var yVals = [ChartDataEntry]()
                var xVals = [String]()
                var i=0;
                for (interestName,interestCount) in interests {
                    interestsText += interestName + " (" + String(interestCount) + ")\n"
                    yVals.append(ChartDataEntry(value: Double(interestCount), xIndex: i))
                    xVals.append(interestName)
                    i++
                }
                var radarChartDataSet = RadarChartDataSet(yVals: yVals, label: "Interests")
                radarChartDataSet.lineWidth = 2.0
                radarChartDataSet.drawFilledEnabled = true
                let radarChartDataSets = [radarChartDataSet]
                let radarChartData = RadarChartData(xVals: xVals, dataSets: radarChartDataSets)
                radarChartData.setDrawValues(false)
                interestsRadarChartView.data = radarChartData
                interestsRadarChartView.setNeedsDisplay()
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

    @IBAction func deleteProfileAction(sender: AnyObject) {
        let contextServerSession : ContextServerSession = ContextServerSession()
        contextServerSession.contextRequested=false
        if (contextServerSession.areServicesAvailable()) {
            if let cxsContext = contextServerSession.currentContext {
                contextServerSession.deleteProfile(cxsContext.profileId!)
            }
        }
    }

    @IBAction func anonymizeProfileAction(sender: AnyObject) {
        let contextServerSession : ContextServerSession = ContextServerSession()
        contextServerSession.contextRequested=false
        if (contextServerSession.areServicesAvailable()) {
            if let cxsContext = contextServerSession.currentContext {
                contextServerSession.anonymizeProfile(cxsContext.profileId!)
            }
        }
    }
    
    @IBAction func resetProfileInterestsAction(sender: AnyObject) {
        let contextServerSession : ContextServerSession = ContextServerSession()
        contextServerSession.contextRequested=false
        if (contextServerSession.areServicesAvailable()) {
            if let cxsContext = contextServerSession.currentContext {
                contextServerSession.removeProperty(cxsContext.profileId!, propertyName: "interests")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
