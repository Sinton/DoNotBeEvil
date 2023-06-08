//
//  AppDelegate.swift
//  DoNotBeEvil
//
//  Created by Yan on 2022/10/17.
//  Copyright © 2022 Yan. All rights reserved.
//

import UIKit
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                // 用户已授权，可以访问日历事件数据
                DispatchQueue.main.async {
                    // 在主线程上执行逻辑
                    print("===finish====")
                }
            } else {
            }
        }
        return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

