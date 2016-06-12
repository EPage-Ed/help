//
//  AddHelpMeVC.swift
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

protocol AddHelpMeDelegate {
    func addPerson(person:HelpMe)
}

class AddHelpMeVC: UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var delegate : AddHelpMeDelegate?

    @IBOutlet weak var avatarButton: UIButton! {
        didSet {
            avatarButton.layer.cornerRadius = avatarButton.frame.size.height / 2
            avatarButton.layer.masksToBounds = true
        }
    }
    @IBAction func avatarHit(sender: UIButton) {
        let pick = UIImagePickerController()
        pick.sourceType = .Camera
        pick.delegate = self
        
        presentViewController(pick, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cycleIV: UIImageView!
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.layer.cornerRadius = 8
            addButton.layer.masksToBounds = true
        }
    }
    @IBAction func addHit(sender: UIButton) {
        let img = avatarButton.imageView!.image!
        let data = UIImageJPEGRepresentation(img, 0.9)!
        let name = nameTF.text!
        let person = HelpMe(name: name, avatar: data, major: myMajor, minor: myMinor)
        person.writeToServer()
        delegate?.addPerson(person)
    }
    
    private var manager : CLLocationManager!
    private var alertSoundPlayer : AVAudioPlayer!
    private let alertSound = NSBundle.mainBundle().URLForResource("sonar", withExtension: "mp3")!

    private var beaconRegion : CLBeaconRegion?
    private var myMajor : Int = 0
    private var myMinor : Int = 0
    private var animating = true
    
    
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
            codeLabel.text = "\(myMajor)-\(myMinor)"
            addButton.enabled = true
            addButton.alpha = 1
            
            return
        }

        // Do any additional setup after loading the view.
        animateCycle(true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if myMajor == 0 {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                manager.requestWhenInUseAuthorization()
            } else if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
                finishTrack()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if let region = beaconRegion {
            manager.stopMonitoringForRegion(region)
            manager.stopRangingBeaconsInRegion(region)
        }
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
    
    
    // TextField
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    
    // Avatar
    
    private func imageByCroppingImage(image : UIImage, size : CGSize) -> UIImage{
        let refWidth : CGFloat = CGFloat(CGImageGetWidth(image.CGImage))
        let refHeight : CGFloat = CGFloat(CGImageGetHeight(image.CGImage))
        
        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        
        let cropRect = CGRectMake(x, y, size.height, size.width)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect)
        
        let cropped : UIImage = UIImage(CGImage: imageRef!, scale: 0, orientation: image.imageOrientation)
        
        
        return cropped
    }
    
    func scaleUIImageToSize(image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }


    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let img = scaleUIImageToSize(imageByCroppingImage(image, size: CGSize(width: image.size.width,height: image.size.width)), size: CGSize(width: 200, height: 200))
            avatarButton.setImage(img, forState: .Normal)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Beacon
    
    func finishTrack() {
        let uuid = NSUUID(UUIDString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, major:31, identifier: "BeaconTag")
//        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "BeaconTag")
        
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
                infoLabel.text = "Got It!"
                alertSoundPlayer.play()
                print(beacon.major, beacon.minor)
                manager.stopMonitoringForRegion(region)
                manager.stopRangingBeaconsInRegion(region)
                
                myMajor = beacon.major.integerValue
                myMinor = beacon.minor.integerValue
                
//                nameTF.userInteractionEnabled = false
                animateCycle(false)
                
                codeLabel.text = "\(myMajor)-\(myMinor)"
                addButton.enabled = true
                addButton.alpha = 1
                
                break
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print("Beacon range failed")
        UIAlertView(title: "Error", message: "Beacon Range Failed", delegate: nil, cancelButtonTitle: "OK").show()
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
