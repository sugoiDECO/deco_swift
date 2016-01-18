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
    let beaconKey = "beacons"
    var beacons: [String] = []

    init() {
        userDefault = NSUserDefaults.standardUserDefaults()
    }
    
    var appearedTask: AnyObject? {
        get {
            print("getter")
            if (userDefault.objectForKey(beaconKey) != nil) {
                print("登録が１つでもあります")
                return userDefault.objectForKey(beaconKey)
            } else {
                print("登録がありません")
                return nil
            }
            
        }
        set(newValue) {
            print("setter")
            //値が来ます
            print(newValue as! String)
            //userDefaultがあるか、なければ作成
            if ((userDefault.objectForKey(beaconKey) != nil)) {
                beacons = userDefault.objectForKey(beaconKey) as! [String]
                //userDefaultにnewValueがなければ追加
                if (!beacons.contains(newValue as! String)) {
                    beacons.append(newValue as! String)
                    userDefault.setObject(beacons, forKey: beaconKey)
                }
            } else {
                print("まだUserDefaultに登録されていません")
                userDefault.setObject(beacons, forKey: beaconKey)
            }
            
            print("beacons")
            print(beacons)
            
        }
    }
    
    func setBeaconId(beaconId: String) {
        userDefault.setBool(false, forKey: beaconId)
    }

    
}