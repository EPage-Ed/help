//
//  HelpMe.swift
//  Help
//
//  Created by Edward Arenberg on 6/11/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import Foundation
import CoreLocation
import AWSCore
import AWSDynamoDB

// KEY AKIAIKMPWLEGJBBZSN6Q
// SECRET 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
// console https://704471219635.signin.aws.amazon.com/console
// us-east-1:d329224c-a069-4b2c-bc2b-92022c3bb12e
// Regions.US_EAST_1


struct Donation {
    let amount : Double
    let time : Double
    let lat : Double
    let lng : Double
    
    func toDict() -> NSDictionary {
        let dict = ["amount":amount,"time":time,"lat":lat,"lng":lng]
        return dict
    }
    static func fromDict(dict:NSDictionary) -> Donation {
        let donation = Donation(
            amount: dict["amount"] as? Double ?? 0,
            time: dict["time"] as? Double ?? 0,
            lat: dict["lat"] as? Double ?? 0,
            lng: dict["lng"] as? Double ?? 0)
        return donation
    }
}

struct Observation {
    let time : Double
    let lat : Double
    let lng : Double
    
    func toDict() -> NSDictionary {
        let dict = ["time":time,"lat":lat,"lng":lng]
        return dict
    }
    static func fromDict(dict:NSDictionary) -> Observation {
        let obs = Observation(
            time: dict["time"] as? Double ?? 0,
            lat: dict["lat"] as? Double ?? 0,
            lng: dict["lng"] as? Double ?? 0)
        return obs
    }
}

class HelpMeAWS : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    static func dynamoDBTableName() -> String {
        return "HelpMe"
    }
    static func hashKeyAttribute() -> String {
        return "id"
    }
    
    var id = ""
    var name = ""
    var avatar = ""
    var major = 0
    var minor = 0
    var donations = ""
    var observations = ""
    
    init(help:HelpMe) {
        id = "\(help.major)-\(help.minor)"
        name = help.name
        major = help.major
        minor = help.minor
        
        let base64String = help.avatar.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        avatar = base64String
        
        let hm = help.donations.map{$0.toDict()}
        let dd = try! NSJSONSerialization.dataWithJSONObject(hm, options: NSJSONWritingOptions())
        let ds = dd.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        donations = ds
        
        let ho = help.observations.map{$0.toDict()}
        let od = try! NSJSONSerialization.dataWithJSONObject(ho, options: NSJSONWritingOptions())
        let os = od.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        observations = os
        
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: ()) throws {
        try super.init(dictionary: dictionaryValue, error: ())
        
    }
    
    required init!(coder: NSCoder!) {
        super.init(coder: coder)
    }
    
    func convert() -> HelpMe {
        var av = NSData()
        if let ad = NSData(base64EncodedString: avatar, options: NSDataBase64DecodingOptions()) {
            av = ad
        }
        
        let help = HelpMe(name: name, avatar: av, major: major, minor: minor)
        
        let dd = NSData(base64EncodedString: donations, options: NSDataBase64DecodingOptions())!
        let ds = try! NSJSONSerialization.JSONObjectWithData(dd, options: NSJSONReadingOptions()) as! NSArray
        let hm = ds.map{ Donation.fromDict($0 as! NSDictionary) }
        help.donations = hm
        
        let od = NSData(base64EncodedString: observations, options: NSDataBase64DecodingOptions())!
        let os = try! NSJSONSerialization.JSONObjectWithData(od, options: NSJSONReadingOptions()) as! NSArray
        let ho = os.map{ Observation.fromDict($0 as! NSDictionary) }
        help.observations = ho
        
//        help.donations = [Donation]()
//        help.observations = [Observation]()
        
        return help
    }

    
    func save() {
        let dynamoDBObjectMapper : AWSDynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper.save(self, completionHandler: {error in
            print(error)
        })
    }
    
    static func load(key:String,callback:(HelpMeAWS)->()) {
        let dynamoDBObjectMapper : AWSDynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper.load(self, hashKey: key, rangeKey: nil).continueWithBlock({task in
            if let result = task.result as? HelpMeAWS {
                callback(result)
            }
            return nil
        })
    }
    
    static func readFromServer(callback:([HelpMeAWS])->()) {
        var helpList = [HelpMeAWS]()
        let dynamoDBObjectMapper : AWSDynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scan = AWSDynamoDBScanExpression()
        scan.limit = 20
        dynamoDBObjectMapper.scan(self, expression: scan).continueWithBlock({task in
//            print(task.dynamicType)
//            dump(task)
            
            if let result = task.result as? AWSDynamoDBPaginatedOutput {
                for help in result.items {
                    if let h = help as? HelpMeAWS {
                        helpList.append(h)
                    }
                }
            }
            callback(helpList)
            
            return nil
        })
        
    }
    
}

class HelpMe {
    
    let name : String
    let avatar : NSData
    let major : Int
    let minor : Int
    var donations = [Donation]()
    var observations = [Observation]()
    var total : Double {
        return donations.reduce(0.0) {$0 + $1.amount}
    }
    var daily : Double {
        let comp = NSDate().timeIntervalSince1970 - 7 * 24 * 3600
        let sum = donations.reduce(0.0) {$0 + ((comp < $1.time) ? $1.amount : 0)}
        return sum / 7
    }
    
    init(name:String,avatar:NSData,major:Int,minor:Int) {
        self.name = name
        self.avatar = avatar
        self.major = major
        self.minor = minor
    }
    
    /*
    required init!(coder: NSCoder!) {
        self.name = ""
        self.avatar = NSData()
        self.major = 0
        self.minor = 0
        super.init(coder: coder)
    }
     */
    
    func addDonation(donation:Donation) {
        donations.append(donation)
        writeToServer()
    }
    
    func addObservation(location:CLLocation) {
        observations.append(Observation(time: NSDate().timeIntervalSince1970, lat: location.coordinate.latitude, lng: location.coordinate.longitude))
        
        writeToServer()
    }
    
    func dictValue() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["name"] = name
        dict["avatar"] = avatar
        dict["major"] = major
        dict["minor"] = minor
        dict["donations"] = donations.map{$0.toDict()}
        dict["observations"] = observations.map{$0.toDict()}
        return dict
    }
    
    static func fromDict(dict:NSDictionary) -> HelpMe {
        let help = HelpMe(
            name: dict["name"] as? String ?? "",
            avatar: dict["avatar"] as? NSData ?? NSData(),
            major: dict["major"] as? Int ?? 0,
            minor: dict["minor"] as? Int ?? 0)
        if let donations = dict["donations"] as? [Donation] {
            help.donations = donations
        }
        if let observations = dict["observations"] as? [Observation] {
            help.observations = observations
        }
        dump(help.donations)
        dump(help.observations)

        return help
    }
    
    func writeToServer() {
        
        let dyn = HelpMeAWS(help: self)
        dyn.save()
        
        
        /*
        return
        
        
        let key = "\(major)-\(minor)"
        var vals = NSMutableDictionary()
        if let server = NSUserDefaults.standardUserDefaults().objectForKey("HelpMeList") as? NSMutableDictionary {
            vals = NSMutableDictionary(dictionary: server)
        }
        vals[key] = dictValue()
        NSUserDefaults.standardUserDefaults().setObject(vals, forKey: "HelpMeList")
        NSUserDefaults.standardUserDefaults().synchronize()
         */
    }
    
    static func readFromServer(completion:([HelpMe])->()) {
        
        HelpMeAWS.readFromServer() {helpList in
            let hm = helpList.map { $0.convert() }
            completion(hm)
        }
        

        /*
        var help = [HelpMe]()
        var vals = NSDictionary()
        if let server = NSUserDefaults.standardUserDefaults().objectForKey("HelpMeList") as? [String:NSDictionary] {
            vals = server
        }
        for (_,val) in vals {
            if let val = val as? NSDictionary {
                let h = HelpMe.fromDict(val)
                help.append(h)
            }
        }
        
        return help
         */
    }
    
    static func loadBeacon(major:Int,minor:Int,callback:(HelpMe)->()) {
        HelpMeAWS.load("\(major)-\(minor)") {ha in
            let help = ha.convert()
            callback(help)
        }
    }
    
}