//
//  AppDelegate.swift
//  TodoList
//
//  Created by Fiona Miao on 3/4/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
             _ = try Realm()
        } catch {
            print("Error initiallizing new realm \(error)")
        }
        
        
        return true
    }



}

