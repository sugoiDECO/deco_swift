//
//  Config.swift
//  deco
//
//  Created by Shinnosuke Komiya on 2015/12/28.
//  Copyright © 2015年 DesignCat Inc. All rights reserved.
//

import Foundation

class Config {
    let userDefault: NSUserDefaults
    
    init() {
        userDefault = NSUserDefaults.standardUserDefaults()
    }
    
    var appearedTask: AnyObject {
        get {
            return userDefault.objectForKey(self.appearedTask as! String)!
        }
        set {
            
        }
    }
    
}