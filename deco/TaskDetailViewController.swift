//
//  TaskDetailViewControler.swift
//  deco
//
//  Created by Shinnosuke Komiya on 2015/12/27.
//  Copyright © 2015年 DesignCat Inc. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class TaskDetailViewController: UIViewController {
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var taskActions: UITextView!
    @IBOutlet weak var taskWays: UITextView!
    @IBOutlet weak var completeBtn: UIButton!
    var taskId: String! = ""
    var config = Config()
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        title = appDelegate.taskTitle
        taskTitle.text = appDelegate.taskTitle
        taskDescription.text = appDelegate.taskDescription
        taskActions.text = ""
        taskWays.text = ""

        for action in appDelegate.taskActions {
            taskActions.text = taskActions.text + "・" + (action as! String) + "\n"
        }
        
        for way in appDelegate.taskWays {
            taskWays.text = taskWays.text + "・" + (way as! String) + "\n"
        }
        updateStatus()

    }
    
    override func viewWillAppear(animated: Bool) {
        taskId = appDelegate.taskId
        print("taskIdは>>>>>>>>>>>>>>" + taskId)
        print("Statusは" + String(config.userDefault.boolForKey(taskId)))
        updateStatus()

    }
    
    override func viewDidLayoutSubviews() {
        var frame = taskDescription.frame
        frame.size.height = taskDescription.contentSize.height
        taskDescription.frame = frame
        fixDescriptionHeight()
        fixActionsHeight()
        fixWaysHeight()
        
    }
    
    class func getViewControllerWithTaskId(taskId: Int) -> TaskDetailViewController {
        let storyboard = UIStoryboard(name: "TaskDetail", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! TaskDetailViewController
        return controller
    }
    
    private func fixDescriptionHeight() {
        let fixedWidth = taskDescription.frame.size.width
        let newSize = taskDescription.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
        var newFrame = taskDescription.frame
        newFrame.size = CGSizeMake(max(newSize.width, fixedWidth), newSize.height)
        taskDescription.frame = newFrame
    }
    
    private func fixActionsHeight() {
        let fixedWidth = taskActions.frame.size.width
        let newSize = taskActions.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
        var newFrame = taskActions.frame
        newFrame.size = CGSizeMake(max(newSize.width, fixedWidth), newSize.height)
        taskActions.frame = newFrame
    }
    
    private func fixWaysHeight() {
        let fixedWidth = taskWays.frame.size.width
        let newSize = taskWays.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
        var newFrame = taskWays.frame
        newFrame.size = CGSizeMake(max(newSize.width, fixedWidth), newSize.height)
        taskWays.frame = newFrame
    }
    
    @IBAction func tapCompleteBtn (sender: AnyObject) {
        let alert:UIAlertController = UIAlertController(title:"タスクを完了しますか？",
            message: "",
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
                
                let okAlert:UIAlertController = UIAlertController(title:"タスク完了！",
                    message: "",
                    preferredStyle: UIAlertControllerStyle.Alert)
                let OKAction:UIAlertAction = UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler:{
                        (action:UIAlertAction!) -> Void in
                        //task終了フラグを立てる
                        self.config.userDefault.setBool(true, forKey: self.taskId)
                        self.config.userDefault.synchronize()
                        var totalCount = self.config.userDefault.integerForKey("finishTaskCount")
                        totalCount++
                        self.config.userDefault.setInteger(totalCount, forKey: "finishTaskCount")
                        self.updateStatus()
                        self.sendToServer()
                })
                okAlert.addAction(OKAction)
                self.presentViewController(okAlert, animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateStatus() {
        if(config.userDefault.boolForKey(taskId) == true) {
            print("ud" + String(config.userDefault.boolForKey(taskId)))
            completeBtn.alpha = 0.4
            completeBtn.enabled = false
        }
    }
    
    func sendToServer() {
        let requestBody = [
            "issue": [
                "project_id": "60",
                "subject": "Task from iPad(" + appDelegate.ipadName + ")" + "taskIdは" + taskId,
                "geometry": appDelegate.geometry,
                "assigned_to_id": appDelegate.ipadName,
                "status_id": "3"
            ]
        ]
        
        SVProgressHUD.show()

        let user = appDelegate.user
        let password = appDelegate.password
        
        let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        Alamofire.request(.POST, appDelegate.baseUrl + appDelegate.endPoint, parameters: requestBody, encoding: .JSON, headers: headers)
            .responseJSON { response in
                print(response)
                SVProgressHUD.dismiss()
            }
    }
    //AlertViewのrootを現在のViewに渡す
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().keyWindow?.rootViewController = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
