//
//  ViewController.swift
//  Help
//
//  Created by Edward Arenberg on 6/11/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

class ViewController: UIViewController, HelpDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanSpinner: UIActivityIndicatorView!
    
    var helpList = [HelpMe]()

//    private var manager : CLLocationManager!
//    private var alertSoundPlayer : AVAudioPlayer!
//    private let alertSound = NSBundle.mainBundle().URLForResource("sonar", withExtension: "mp3")!

//    private var beaconRegion : CLBeaconRegion?

    override func awakeFromNib() {
//        manager = CLLocationManager()
//        manager.delegate = self
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        alertSoundPlayer = try? AVAudioPlayer(contentsOfURL: alertSound)
//        alertSoundPlayer.prepareToPlay()
        
        HelpLib.instance.delegate = self
        HelpLib.instance.startTracking()
        
        if Platform.isSimulator {
            HelpMe.loadBeacon(31, minor: 100) {
                help in
                self.helpList.append(help)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
//                help.addObservation(HelpLib.instance.curLocation!)
            }
        }
    }

    deinit {
//        if let region = beaconRegion {
//            manager.stopMonitoringForRegion(region)
//            manager.stopRangingBeaconsInRegion(region)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - HelpLib Delegate
    func seeBeacons(beacons: [CLBeacon]) {
        for beacon in beacons {
            // TODO: Use beacon value!!
            
            let major : Int = Platform.isSimulator ? 31 : beacon.major.integerValue
            let minor : Int = Platform.isSimulator ? 100 : beacon.minor.integerValue
//            HelpMe.loadBeacon(beacon.major, minor: beacon.minor) {
            HelpMe.loadBeacon(31, minor: 100) {
//            HelpMe.loadBeacon(major, minor: minor) {
                help in
                self.helpList.append(help)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
                help.addObservation(HelpLib.instance.curLocation!)
            }
        }
    }

    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HelpCell", forIndexPath: indexPath)
        
        let help = helpList[indexPath.row]
        cell.textLabel?.text = help.name
        cell.imageView?.image = UIImage(data: help.avatar)
        
        let d = help.daily
        if d < 2 {
            cell.accessoryView = UIImageView(image: UIImage(named: "red"))
        } else if d < 5 {
            cell.accessoryView = UIImageView(image: UIImage(named: "blue"))
        } else {
            cell.accessoryView = UIImageView(image: UIImage(named: "green"))
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.font = UIFont.systemFontOfSize(28)
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? GiveVC, sender = sender as? UITableViewCell {
            if let ip = tableView.indexPathForCell(sender) {
                vc.help = helpList[ip.row]
            }
        }
    }

}

