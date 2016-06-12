//
//  PurchaseVC.swift
//  Help
//
//  Created by Edward Arenberg on 6/12/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import UIKit
import CoreLocation

class PurchaseVC: UIViewController {

    var help : HelpMe!
    var location : CLLocation?
    let nf = NSNumberFormatter()
    
    @IBOutlet weak var avatarIV: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bankLabel: UILabel!
    
    @IBOutlet weak var jacketButton: UIButton!
    @IBOutlet weak var blanketButton: UIButton!
    @IBOutlet weak var glovesButton: UIButton!
    
    @IBAction func itemHit(sender: UIButton) {
        sender.selected = !sender.selected
    }
    
    
    @IBOutlet weak var purchaseButton: UIButton! {
        didSet {
            purchaseButton.layer.cornerRadius = 8
            purchaseButton.layer.masksToBounds = true
        }
    }
    @IBAction func purchaseHit(sender: UIButton) {
        var amt = 0.0
        amt += jacketButton.selected ? 15.0 : 0.0
        amt += blanketButton.selected ? 10.0 : 0.0
        amt += glovesButton.selected ? 8.0 : 0.0
        
        if amt > help.total {
            UIAlertView(title: "Too Much", message: "Insufficient funds to cover all the items.", delegate: nil, cancelButtonTitle: "OK").show()
            return
        }
        
        
        let ac = UIAlertController(title: "Confirm", message: "Purchase \(nf.stringFromNumber(amt)!)", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {action in
            let loc = self.location ?? CLLocation()
            let donate = Donation(amount: -amt, time: NSDate().timeIntervalSince1970, lat: loc.coordinate.latitude, lng: loc.coordinate.longitude)
            self.help.addDonation(donate)
            self.navigationController?.popViewControllerAnimated(true)
        }))
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nf.numberStyle = .CurrencyStyle
        
        avatarIV.image = UIImage(data: help.avatar)
        nameLabel.text = help.name
        bankLabel.text = nf.stringFromNumber(help.total)
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
