//
//  TaskCell.swift
//  deco
//
//  Created by Shinnosuke Komiya on 2015/12/28.
//  Copyright © 2015年 DesignCat Inc. All rights reserved.
//

import Foundation

class TaskCell: UITableViewCell {
    var config = Config()
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!
    func setupCell(taskId: String) {
        if (config.userDefault.boolForKey(taskId)) {
            taskTitle.alpha = 0.4
            checkIcon.image = UIImage(named: "checkIcon")
        }
    }
}