//
//  HelpSetupVC.swift
//  Help
//
//  Created by Edward Arenberg on 6/11/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import UIKit

class HelpSetupVC: UIViewController {

    var maxPerDay = 10.0 {
        didSet {
            maxPerDayLabel.text = nf.stringFromNumber(maxPerDay)!
        }
    }
    var dailyCap = 10.0 {
        didSet {
            dailyCapLabel.text = nf.stringFromNumber(dailyCap)!
        }
    }
    var minGive = 5.0
    var maxGive = 80.0
    
    @IBOutlet weak var maxPerDaySlider: UISlider!
    @IBOutlet weak var maxPerDayLabel: UILabel!
    @IBAction func maxPerDayChanged(sender: UISlider) {
        let val = floorf(sender.value * 4) / 4.0
        maxPerDay = Double(val)
    }

    @IBOutlet weak var dailyCapSlider: UISlider!
    @IBOutlet weak var dailyCapLabel: UILabel!
    @IBAction func dailyCapChanged(sender: UISlider) {
        let val = floorf(sender.value * 4) / 4.0
        dailyCap = Double(val)
    }
    
    
    @IBOutlet weak var sliderView: UIView!
    private var autoSlider : NMRangeSlider!

    @IBOutlet weak var minGiveLabel: UILabel!
    @IBOutlet weak var maxGiveLabel: UILabel!
    
    @IBOutlet weak var fundsLabel: UILabel! {
        didSet {
            let funds = NSUserDefaults.standardUserDefaults().doubleForKey("Funds")
            fundsLabel.text = "Funds: \(nf.stringFromNumber(funds)!)"
        }
    }
    @IBAction func addFundsHit(sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Add Funds", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Amount"
            textField.keyboardType = .DecimalPad
            textField.font = UIFont.systemFontOfSize(20)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            var funds = NSUserDefaults.standardUserDefaults().doubleForKey("Funds")
            if let txt = ac.textFields?[0].text, amt = Double(txt) {
                funds += amt
                NSUserDefaults.standardUserDefaults().setDouble(funds, forKey: "Funds")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.fundsLabel.text = "Funds: \(self.nf.stringFromNumber(funds)!)"
            }
        }))
        presentViewController(ac, animated: true, completion: nil)
        
    }
    
    let nf = NSNumberFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nf.numberStyle = .CurrencyStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let slider = NMRangeSlider()
        slider.minimumValue = 1
        slider.maximumValue = 100
        slider.lowerValue = 10
        slider.upperValue = 80
        slider.stepValue = 1
        slider.stepValueContinuously = true
        
        slider.addTarget(self, action: #selector(HelpSetupVC.sliderChanged(_:)), forControlEvents: .ValueChanged)
        
        autoSlider = slider
        sliderView.addSubview(autoSlider)

        
        if let defaults = NSUserDefaults.standardUserDefaults().objectForKey("GiveSettings") as? [String:AnyObject] {
            maxPerDay = defaults["MaxPerDay"] as? Double ?? maxPerDay
            dailyCap = defaults["DailyCap"] as? Double ?? dailyCap
        }
        
        maxPerDay = maxPerDay + 0
        dailyCap = dailyCap + 0
        
        
        sliderChanged(autoSlider)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        autoSlider.frame = CGRect(x: 20, y: sliderView.bounds.size.height - 50, width: sliderView.bounds.size.width - 40, height: 40)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Auto Give
    
    @IBAction func autoGiveOn(sender: UISwitch) {
        sliderView.hidden = !sender.on
    }
    func sliderChanged(slider:NMRangeSlider) {
        minGiveLabel.text = nf.stringFromNumber(slider.lowerValue)!
        maxGiveLabel.text = nf.stringFromNumber(slider.upperValue)!
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
