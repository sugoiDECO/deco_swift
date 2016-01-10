//
//  SprashViewController.swift
//  deco
//
//  Created by Shinnosuke Komiya on 2015/12/28.
//  Copyright © 2015年 DesignCat Inc. All rights reserved.
//

import UIKit

class SprashViewController: UIViewController {
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    var config = Config()
    
    @IBAction func touchUpInsideResetButton(sender:AnyObject) {
        
        let alert:UIAlertController = UIAlertController(title:"DECOをリセットしますか？",
            message: "改めてDECOを行う際にのみリセットしてください",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                let appDomain: String = NSBundle.mainBundle().bundleIdentifier!
                self.config.userDefault.removePersistentDomainForName(appDomain)
                let okAlert:UIAlertController = UIAlertController(title:"DECOをリセットしました",
                    message: "",
                    preferredStyle: UIAlertControllerStyle.Alert)
                let OKAction:UIAlertAction = UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler:{
                        (action:UIAlertAction!) -> Void in
                })
                okAlert.addAction(OKAction)
                self.presentViewController(okAlert, animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)


        

    }
    
    override func viewDidAppear(animated: Bool) {
        self.presentedViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
