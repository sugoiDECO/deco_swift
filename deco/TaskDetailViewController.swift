//
//  TaskDetailViewControler.swift
//  deco
//
//  Created by Shinnosuke Komiya on 2015/12/27.
//  Copyright © 2015年 DesignCat Inc. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    var taskId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    class func getViewControllerWithTaskId(taskId: Int) -> TaskDetailViewController {
        let storyboard = UIStoryboard(name: "TaskDetail", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! TaskDetailViewController
        controller.taskId = taskId
        return controller
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
