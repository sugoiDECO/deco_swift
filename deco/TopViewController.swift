//
//  TopViewController.swift
//  deco
//
//  Created by Shinnosuke Komiya on 2015/12/27.
//  Copyright © 2015年 DesignCat Inc. All rights reserved.
//

import UIKit

class TopViewController: UIViewController, ESTBeaconManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    var config = Config()
    
    private let cellIdentifier = "TaskCell"
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(
        proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
        identifier: "ranged region")
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    //UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalTaskView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Appdelegate
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.topViewController = self
        
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
        title = "タスク一覧"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        reload()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().keyWindow?.rootViewController = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TaskCell
        let beaconName = config.appearedTask![indexPath.row] as! String
        if let title = appDelegate.registeredTask[beaconName]!["title"] as? String {
            cell.taskTitle.text = title
        } else {
            print("jsonエラー")
        }
//        cell.setupCell(appearedTask[indexPath.row], rank: indexPath.row + 1)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if config.appearedTask != nil {
            return config.appearedTask!.count
        } else {
            return 0
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = TaskDetailViewController.getViewControllerWithTaskId(indexPath.row)
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let beaconName = config.appearedTask![indexPath.row] as! String
        appDelegate.taskTitle = appDelegate.registeredTask[beaconName]!["title"] as? String
        appDelegate.taskDescription = appDelegate.registeredTask[beaconName]!["description"] as? String
        appDelegate.taskActions = appDelegate.registeredTask[beaconName]!["actions"] as! NSArray
        appDelegate.taskWays = appDelegate.registeredTask[beaconName]!["ways"] as! NSArray
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    
    
        
    func reload() {
        print("reload tables")
        if config.appearedTask != nil {
            tableView.hidden = false
            totalTaskView.hidden = false
        } else {
            tableView.hidden = true
            totalTaskView.hidden = true
        }
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

