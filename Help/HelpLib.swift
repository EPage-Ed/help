//
//  HelpLib.swift
//  Help
//
//  Created by Edward Arenberg on 6/11/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

protocol HelpDelegate {
    func seeBeacons(beacons:[CLBeacon])
}

public class HelpLib : NSObject, CLLocationManagerDelegate {
    
    var delegate : HelpDelegate?
    
    private let manager : CLLocationManager!
    private var location : CLLocation?
    private var alertSoundPlayer : AVAudioPlayer!
    private let alertSound = NSBundle.mainBundle().URLForResource("sonar", withExtension: "mp3")!

    public static var instance = HelpLib()
    public var curLocation : CLLocation? {
        return location
    }
    
    override init() {
        manager = CLLocationManager()
        manager.activityType = .Fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.pausesLocationUpdatesAutomatically = false
        super.init()
        manager.delegate = self
        stopRegionMonitoring()
        alertSoundPlayer = try? AVAudioPlayer(contentsOfURL: alertSound)
        alertSoundPlayer.prepareToPlay()
    }
    
    
    public func startTracking() {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestAlwaysAuthorization()
        }
    }
    
    
    
    // MARK: - Location delegate
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            manager.startUpdatingLocation()
            
            // IOTDS D492DB29-7C93-2482-7990-A2DA8C9D9AF9
//            let bt_uuid = NSUUID(UUIDString: "D492DB29-7C93-2482-7990-A2DA8C9D9AF9")!
            let uuid = NSUUID(UUIDString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")!
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 31, identifier: "BeaconScan")
            beaconRegion.notifyEntryStateOnDisplay = true
            beaconRegion.notifyOnEntry = true
//            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "BeaconScan")
            monitorRegion(beaconRegion)
        } else {
            // User does not authorize
            print("ERROR: Location Not Authorized")
        }
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        location = newLocation
    }
    
    // MARK: - Geo Fencing
    
    private func monitorRegion(region : CLBeaconRegion) {
        print("Monitoring Available = \(CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self))")
        if !manager.monitoredRegions.contains(region) {
            manager.startMonitoringForRegion(region)
            //            UIAlertView(title: "Generate", message: "\(region.identifier)\n\((region as! CLCircularRegion).center)", delegate: nil, cancelButtonTitle: "OK").show()
        } else {
            //            UIAlertView(title: "Already Monitoring", message: "\(region.identifier)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    private func stopRegionMonitoring() {
        for region in manager.monitoredRegions {
            manager.stopMonitoringForRegion(region)
        }
    }
    
    public func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("Started Monitoring Region \(region.identifier)")
    }
    
    public func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        print("***** Region \(region.identifier) = \(state.rawValue)")
//        UIAlertView(title: "State", message: "\(region.identifier) = \(state)", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    public func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(">>>>>  Entered Region")
        guard let region = region as? CLBeaconRegion else {
            return
        }
        
        manager.startRangingBeaconsInRegion(region)
        
//        UIAlertView(title: "Entered", message: "\(region.identifier)", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    public func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        manager.stopRangingBeaconsInRegion(region)
        
        delegate?.seeBeacons(beacons)
        
    }
    
    public func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print("Beacon range failed")
//        UIAlertView(title: "Error", message: "Beacon Range Failed", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    public func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("<<<<<  Exited Region")
//        UIAlertView(title: "Exited", message: "\(region.identifier)", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    public func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Region Failed: \(error)")
    }
 
    
    
}
