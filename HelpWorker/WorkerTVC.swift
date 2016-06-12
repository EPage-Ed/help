//
//  WorkerTVC.swift
//  Help
//
//  Created by Edward Arenberg on 6/11/16.
//  Copyright © 2016 Edward Arenberg. All rights reserved.
//

import UIKit
import AWSCore
import AWSDynamoDB

class WorkerTVC: UITableViewController, AddHelpMeDelegate {
    
    var helpList = [HelpMe]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        HelpMeAWS.readFromServer()
        
        
        HelpMe.readFromServer() {items in
            self.helpList.appendContentsOf(items)
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        let listTableInput = AWSDynamoDBListTablesInput()
        dynamoDB.listTables(listTableInput).continueWithBlock{ (task: AWSTask?) -> AnyObject? in
            if let error = task?.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            if let listTablesOutput = task?.result as? AWSDynamoDBListTablesOutput, tableNames = listTablesOutput.tableNames {
            
                for tableName in tableNames {
                    print("\(tableName)")
                }
            }
            
            return nil
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Add
    
    func addPerson(person: HelpMe) {
        helpList.append(person)
        tableView.reloadData()
        navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HelpMeCell", forIndexPath: indexPath)

        // Configure the cell...
        let help = helpList[indexPath.row]
        cell.textLabel?.text = help.name
        cell.imageView?.image = UIImage(data: help.avatar ?? NSData())

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.font = UIFont.systemFontOfSize(28)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? AddHelpMeVC {
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? HelpMeVC, sender = sender as? UITableViewCell {
            if let ip = tableView.indexPathForCell(sender) {
                vc.title = sender.textLabel?.text
                vc.help = helpList[ip.row]
            }
        }
    }

}
