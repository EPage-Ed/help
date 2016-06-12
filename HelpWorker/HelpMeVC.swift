//
//  HelpMeVC.swift
//  Help
//
//  Created by Edward Arenberg on 6/11/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import UIKit
import ArcGIS

class HelpMeVC: UIViewController, AGSMapViewLayerDelegate, AGSWebMapDelegate {
    
    var help : HelpMe!

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var avatarIV: UIImageView!
    @IBOutlet weak var dailyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        avatarIV.image = UIImage(data: help.avatar ?? NSData())
        let nf = NSNumberFormatter()
        nf.numberStyle = .CurrencyStyle
        let daily = nf.stringFromNumber(help.daily)!
        dailyLabel.text = "\(daily) / Day"
        
        let url = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer")
        let tiledLayer = AGSTiledMapServiceLayer(URL: url)
        self.mapView.addMapLayer(tiledLayer, withName: "Basemap Tiled Layer")

        self.mapView.layerDelegate = self

//        let ref = AGSSpatialReference()
//        let env = AGSEnvelope(spatialReference: ref)
//        mapView.centerAtPoint(mapView, animated: <#T##Bool#>)
        
        
//        let cred = AGSCredential(user: "", password: "")
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Map
    
    func mapViewDidLoad(mapView: AGSMapView!) {
        //do something now that the map is loaded
        //for example, show the current location on the map
        mapView.locationDisplay.startDataSource()

//        let json : [NSObject:AnyObject] = [NSObject:AnyObject]()
//        var mapLayer = AGSFeatureLayer(JSON: json)
//
        

        let mapLayer = AGSFeatureLayer(URL: NSURL(string: "http://services2.arcgis.com/LMBdfutQCnDGYUyc/arcgis/rest/services/Los_Angeles_County_Homeless_Programs_Services/FeatureServer/0")!, mode: AGSFeatureLayerMode.OnDemand)
        mapView.addMapLayer(mapLayer)

        let layer2 = AGSFeatureLayer(URL: NSURL(string:"http://services2.arcgis.com/PmX3KsvHLzk1y5Hn/arcgis/rest/services/give/FeatureServer/0")!, mode: AGSFeatureLayerMode.OnDemand)
        mapView.addMapLayer(layer2)
        

    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

//        let webmap = AGSWebMap(itemId: "c8bee1d49d6e4d4f914c49d87d944da8", credential: nil)
//        webmap.delegate = self
//        webmap.openIntoMapView(mapView)

        let pt = mapView.locationDisplay.mapLocation()
        
        mapView.zoomToScale(8, withCenterPoint: pt, animated: true)
        
    }
    
    func webMapDidLoad(webMap: AGSWebMap!) {
        print("Web Map Loaded")
    }
    
    func webMap(webMap: AGSWebMap!, didFailToLoadWithError error: NSError!) {
        print(error)
    }
    
    func didOpenWebMap(webMap: AGSWebMap!, intoMapView mapView: AGSMapView!) {
        print("Opened")
    }
    
    func webMap(webMap: AGSWebMap!, didFailToLoadLayer layerInfo: AGSWebMapLayerInfo!, baseLayer: Bool, federated: Bool, withError error: NSError!) {
        print(error)
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
