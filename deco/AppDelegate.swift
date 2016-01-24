//
//  AppDelegate.swift
//  deco
//
//  Created by Shinnosuke Komiya on 2015/12/13.
//  Copyright © 2015年 DesignCat Inc. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var topViewController: TopViewController!
    let beaconManager = ESTBeaconManager()
    var config = Config()
    var registeredTask = [:]

    var taskId: String?
    var taskTitle: String?
    var taskDescription: String?
    var taskActions = []
    var taskWays = []
    
    let rangeOfBeacon: Int = 3
    //A→109、B→110
    let ipadName = "110"
    
    var baseUrl: String = "http://beta.shirasete.jp"
    var endPoint: String = "/projects/60/issues.json"
    let user = "kurohune538"
    let password = "12345678"
    
    var lng: Double = 0
    var lat: Double = 0
    var geometry: String = ""
    var locationManager: CLLocationManager!
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(
            proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
            identifier: "monitored region"))
        let beaconRegion = CLBeaconRegion(
            proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
            identifier: "ranged region")
        self.beaconManager.startRangingBeaconsInRegion(beaconRegion)
        
        loadTask()
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        
        locationManager = CLLocationManager()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 30
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        
        geometry = "{\"type\":\"Point\",\"coordinates\":[\(lng),\(lat)]}"
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("deco", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //Task.jsonを読み込み
    func loadTask() {
        let path : String = NSBundle.mainBundle().pathForResource("Task", ofType: "json")!
        let fileHandle : NSFileHandle = NSFileHandle(forReadingAtPath: path)!
        let data : NSData = fileHandle.readDataToEndOfFile()
        do {
            let json: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            registeredTask = json
            
        } catch let error as NSError {
            print("error!!!")
            print(error.localizedDescription)
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        lat = newLocation.coordinate.latitude
        lng = newLocation.coordinate.longitude
        geometry = "{\"type\":\"Point\",\"coordinates\":[\(lng),\(lat)]}"
        // 取得した緯度・経度をLogに表示
        NSLog("latiitude: \(lat) , longitude: \(lng)")
        
        //位置を本部に送信
        let requestBody = [
            "issue": [
                "project_id": "60",
                "subject": "Post from iPad(" + ipadName + ")",
                "geometry": geometry,
                "assigned_to_id": ipadName,
                "status_id": "1"
            ]
        ]
        let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        Alamofire.request(.POST, baseUrl + endPoint, parameters: requestBody, encoding: .JSON, headers: headers)
            .responseJSON { response in
                print(response)
        }
//        locationManager.stopUpdatingLocation()
    }
    
 
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Error")
    }
    
    //Estimote
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        print("検知！")
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        let notification = UILocalNotification()
        notification.alertBody =
            "Estimoteから離れたよ" +
            manager.name
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon],
        inRegion region: CLBeaconRegion) {
        if let nearestBeacon = beacons.first {
            //let places = placesNearBeacon(nearestBeacon)
            //検知の距離を指定
            if(nearestBeacon.proximity.rawValue < rangeOfBeacon) {
                //major:minor値をフォーマット化
                let major: String = String(nearestBeacon.major)
                let minor: String = String(nearestBeacon.minor)
                let beaconKey: String = major + ":" + minor
                    
                print("近くにBeacon(" + beaconKey + ")があります")
                if ((registeredTask[beaconKey]) != nil) {
                    print("このBeaconは" + String(registeredTask[beaconKey]))
                    if (config.appearedTask != nil) {
                        let appearedBeacons = config.appearedTask as! [String]
                        //発見されたBeaconKeyがまだ登録されたものでなければ通知する
                        if (!appearedBeacons.contains(beaconKey)) {
                        
                            config.setBeaconId(registeredTask[beaconKey]!["id"] as! String)
                            //通知を送信
                            let notification = UILocalNotification()
                            notification.alertBody =
                                "次のミッションだ！" +
                                "タスクを確認しろ！"
                            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                                
                            //アプリを開いた状態の際の通知はこちら
                            let alert:UIAlertController = UIAlertController(title:"次のミッションだ！",
                                message: "タスクを確認しろ！",
                                preferredStyle: UIAlertControllerStyle.Alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(defaultAction)
                                
                            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            print(beaconKey + "は既に表示されているBeaconです")
                        }
                        
                    } else {
                            
                    }
                    //beaconKeyを登録
                    config.appearedTask = beaconKey
                        //リストのViewの時はリロードする
                    if (UIApplication.sharedApplication().keyWindow?.rootViewController == topViewController) {
                        topViewController.reload()
                    }
                } else {
                    print("登録されていないBeaconです")
                }
            } else {
                print("近くにBeaconがありません")
            }
        }
    }
}

