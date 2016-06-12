//
//  MerchantVC.swift
//  Help
//
//  Created by Edward Arenberg on 6/12/16.
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


class MerchantVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cycleIV: UIImageView!

    private var manager : CLLocationManager!
    private var alertSoundPlayer : AVAudioPlayer!
    private let alertSound = NSBundle.mainBundle().URLForResource("sonar", withExtension: "mp3")!

    private var beaconRegion : CLBeaconRegion?
    private var myMajor : Int = 0
    private var myMinor : Int = 0
    private var animating = true

    var curLocation : CLLocation?
    var help : HelpMe!
    
    override func awakeFromNib() {
        manager = CLLocationManager()
        manager.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertSoundPlayer = try? AVAudioPlayer(contentsOfURL: alertSound)
        alertSoundPlayer.prepareToPlay()
        
        if Platform.isSimulator {
            myMajor = 31
            myMinor = 100

            HelpMe.loadBeacon(31, minor: 100) {
                //            HelpMe.loadBeacon(major, minor: minor) {
                help in
                
                self.help = help
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("SeeBeacon", sender: self)
                }
                
                if let curLocation = self.curLocation {
                    help.addObservation(curLocation)
                }
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        myMajor = 0
        myMinor = 0
        animateCycle(true)

//        if myMajor == 0 {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                manager.requestWhenInUseAuthorization()
            } else if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
                finishTrack()
            }
//        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Animate
    
    func animateCycle(animate:Bool) {
        animating = animate
        if !animate {
            cycleIV.transform = CGAffineTransformIdentity
        } else {
            self.animate()
        }
    }
    
    func animate() {
        dispatch_async(dispatch_get_main_queue()) {
            self.rotateCircle(self.cycleIV,count:1000)
        }
    }
    private func rotateCircle(circle : UIImageView, count:Int) {
        if count <= 0 || !animating {
            return
        }
        UIView.animateWithDuration(0.5, delay:0, options: .CurveLinear ,animations:  {
            self.cycleIV.transform = CGAffineTransformRotate(circle.transform, CGFloat(M_PI_2))
            }, completion: {finished in
                self.rotateCircle(circle,count:count - 1)
        })
    }
    

    // Beacon
    
    func finishTrack() {
        let uuid = NSUUID(UUIDString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, major:31, identifier: "BeaconTag")
        //        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "BeaconTag")
        
        manager.startUpdatingLocation()

        beaconRegion!.notifyEntryStateOnDisplay = true
        beaconRegion!.notifyOnEntry = true
        manager.startMonitoringForRegion(beaconRegion!)
        manager.startRangingBeaconsInRegion(beaconRegion!)
    }
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            finishTrack()
        } else {
            // User does not authorize
            print("ERROR: Location Not Authorized")
        }
    }
    
    
    public func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        curLocation = newLocation
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(">>>>>  Entered Region")
        guard let region = region as? CLBeaconRegion else {
            return
        }
        
        //        manager.startRangingBeaconsInRegion(region)
        
    }
    
    
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        for beacon in beacons {
            if beacon.proximity == .Immediate {
                alertSoundPlayer.play()
                print(beacon.major, beacon.minor)
                manager.stopMonitoringForRegion(region)
                manager.stopRangingBeaconsInRegion(region)
                
                myMajor = beacon.major.integerValue
                myMinor = beacon.minor.integerValue
                
                //                nameTF.userInteractionEnabled = false
//                animateCycle(false)
                
                break
            }
        }
        
        if myMinor != 0 {
            
            HelpMe.loadBeacon(31, minor: 100) {
                //            HelpMe.loadBeacon(major, minor: minor) {
                help in

                self.help = help
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("SeeBeacon", sender: self)
                }

                if let curLocation = self.curLocation {
                    help.addObservation(curLocation)
                }
            }

            
            manager.stopMonitoringForRegion(beaconRegion!)
            manager.stopRangingBeaconsInRegion(beaconRegion!)
        }
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print("Beacon range failed")
        UIAlertView(title: "Error", message: "Beacon Range Failed", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let vc = segue.destinationViewController as? PurchaseVC {
            vc.help = help
            vc.location = curLocation
        }
    }

}
