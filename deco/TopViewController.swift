//
//  TopViewController.swift
//  deco
//
//  Created by Shinnosuke Komiya on 2015/12/27.
//  Copyright © 2015年 DesignCat Inc. All rights reserved.
//

import UIKit

class TopViewController: UIViewController, ESTBeaconManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let placesByBeacons = [
        //紫
        "34433:43466": [
            "title":"むらさきだよ",
            "description":"クエストはこれだよ"
        ],
        //水色
        "52956:29906": [
            "title":"水色だよ"
            
        ],
        //黄緑
        "27426:10315": [
            "title":"黄緑だよ"
        ]
    ]
    
    var registeredTask: [AnyObject] = []
    var appearedTask: [AnyObject] = ["ss"]
    
    private let cellIdentifier = "TaskCell"
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(
        proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
        identifier: "ranged region")
    
    //UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalTaskView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
        

        title = "タスク一覧"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        loadTask()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if appearedTask.count > 0 {
            tableView.hidden = false
            totalTaskView.hidden = false
        }
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TaskCell
//        cell.setupCell(appearedTask[indexPath.row], rank: indexPath.row + 1)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appearedTask.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = TaskDetailViewController.getViewControllerWithTaskId(appearedTask.count)
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon],
        inRegion region: CLBeaconRegion) {
            let beaconsArray:Array = beacons
            if let nearestBeacon = beacons.first {
                let places = placesNearBeacon(nearestBeacon)
                print(nearestBeacon)
                //print(beaconsArray)
                
                // TODO: update the UI here
                //print(places.first!["title"] as! String) // TODO: remove after implementing the UI
            }
    }
    
    func placesNearBeacon(beacon: CLBeacon) -> [AnyObject] {
        let beaconKey = "\(beacon.major):\(beacon.minor)"
        if let places = self.placesByBeacons[beaconKey] {
            let sortedPlaces = Array(arrayLiteral: places)
            return sortedPlaces
        }
        return []
    }
    
    //Task.jsonを読み込み
    private func loadTask() {
        let path : String = NSBundle.mainBundle().pathForResource("Task", ofType: "json")!
        let fileHandle : NSFileHandle = NSFileHandle(forReadingAtPath: path)!
        let data : NSData = fileHandle.readDataToEndOfFile()
        do {
            if let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments) as? NSDictionary{
                    
                print(json)

                if let hoge = json["34433:43466"]!["title"] as? String {
//                    self.hoge = hoge
                    print(hoge)
                } else {
                    print ("存在しない値です")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            print("error!!!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

