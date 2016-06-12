//
//  SplashVC.swift
//  Help
//
//  Created by Edward Arenberg on 6/12/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    @IBOutlet weak var splashIV: UIImageView!
    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        timer?.invalidate()
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("MainApp") {
            view.window?.rootViewController = vc
            view.window?.makeKeyAndVisible()
        }
    }
    
    var images : [NSURL]!
    var timer : NSTimer?
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        images = NSBundle.mainBundle().URLsForResourcesWithExtension("jpg", subdirectory: "SplashImages")
        if let url = images?.first {
            if let data = NSData(contentsOfURL: url) {
                splashIV.image = UIImage(data: data)
            }
        }
        index = 1
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(SplashVC.timerFired(_:)), userInfo: nil, repeats: true)
    }
    
    func timerFired(timer:NSTimer) {
        if let url = images?[index] {
            if let data = NSData(contentsOfURL: url) {
                let image2 = UIImage(data: data)!
                let crossFade:CABasicAnimation = CABasicAnimation(keyPath: "contents")
                crossFade.duration = 0.5
                crossFade.fromValue = splashIV.image!.CGImage
                crossFade.toValue = image2.CGImage
                splashIV.layer.addAnimation(crossFade, forKey:"animateContents");
                splashIV.image = image2
                
            }
        }
        index += 1
        if index >= images.count {
            index = 0
        }
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
