//
//  GiveVC.swift
//  Help
//
//  Created by Edward Arenberg on 6/12/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import UIKit
import CoreLocation

class GiveVC: UIViewController {
    
    var help : HelpMe!
    let funds = NSUserDefaults.standardUserDefaults().doubleForKey("Funds")

    @IBOutlet weak var avatarIV: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var giveLabel: UILabel!
    @IBOutlet weak var giveSlider: UISlider!
    @IBAction func giveChanged(sender: UISlider) {
        let val = floorf(sender.value * 4) / 4.0
        giveSlider.value = val
        giveLabel.text = nf.stringFromNumber(sender.value)
    }
    @IBOutlet weak var giveButton: UIButton! {
        didSet {
            giveButton.layer.cornerRadius = 8
            giveButton.layer.masksToBounds = true
        }
    }
    @IBAction func giveHit(sender: UIButton) {
        let amt = Double(giveSlider.value)
        let ac = UIAlertController(title: "Confirm", message: "Donate \(nf.stringFromNumber(amt)!)", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {action in
            let loc = HelpLib.instance.curLocation ?? CLLocation()
            let donate = Donation(amount: amt, time: NSDate().timeIntervalSince1970, lat: loc.coordinate.latitude, lng: loc.coordinate.longitude)
            self.help.addDonation(donate)
//            self.help.donations.append(donate)
//            self.help.writeToServer()
//            UIAlertView(title: "THANK YOU", message: "Your donation is greatly appreciated!", delegate: nil, cancelButtonTitle: "OK").show()
            
            var funds = NSUserDefaults.standardUserDefaults().doubleForKey("Funds")
            funds -= amt
            
            NSUserDefaults.standardUserDefaults().setDouble(funds, forKey: "Funds")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let ac = UIAlertController(title: "THANK YOU", message: "Your donation is greatly appreciated!", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: {action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            self.presentViewController(ac, animated: true, completion: nil)
            
        }))
        presentViewController(ac, animated: true, completion: nil)
        
    }
    
    let nf = NSNumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        nf.numberStyle = .CurrencyStyle

        navigationItem.title = "\(help.major) - \(help.minor)"
        avatarIV.image = UIImage(data: help.avatar)
        
        giveSlider.maximumValue = fmin(50.0,Float(funds))
        giveChanged(giveSlider)
        
        var today = 0.0
        let cal = NSCalendar.currentCalendar()
        for d in help.donations {
            let dt = NSDate(timeIntervalSince1970: d.time)
            if cal.isDateInToday(dt) {
                today += d.amount
            }
        }
        infoLabel.text = "Today: \(nf.stringFromNumber(today)!)"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
