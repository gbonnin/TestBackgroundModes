//
//  AppDelegate.swift
//  TestSilentPush
//
//  Created by Guillaume Bonnin on 18/02/2016.
//  Copyright © 2016 Smart&Soft. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.askRegisterForNotifications()
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    // MARK: - Notifications
    
    func askRegisterForNotifications() {
        NSLog("Application will try to register for remote notifications")
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        NSLog("Application did register for remote notifications with device token : " + String(deviceToken))
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("Application did fail to register for remote notifications with error : " + error.description)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        NSLog("Application did receive remote notification : " + userInfo.description)
        
        if let aps = userInfo["aps"] as? [String: AnyObject],
            contentAvailable = aps["content-available"] as? Int where contentAvailable == 1 {
                NSLog("Notification is a silent push")
                
                // Increments silentPush counter
                let countSilentPush = NSUserDefaults.standardUserDefaults().integerForKey(Constants.CountSilentPushSettings)
                NSUserDefaults.standardUserDefaults().setInteger(countSilentPush + 1, forKey: Constants.CountSilentPushSettings)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                
                // Starts long request process to update UI
                NSLog("Will start background task to process download")
                var bTaskIdentifier: UIBackgroundTaskIdentifier
                bTaskIdentifier = application.beginBackgroundTaskWithExpirationHandler({ () -> Void in
                })
                
                completionHandler(.NewData)
                NSLog("Silent notification action is done with new data, background task now running")
                
                dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 60 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                    if let vc = self.window?.rootViewController as? ViewController {
                        vc.fetchWeather({ () -> Void in
                            application.endBackgroundTask(bTaskIdentifier)
                            bTaskIdentifier = UIBackgroundTaskInvalid
                            NSLog("Background task is done !")
                        })
                    }
                }
        }
        else {
                completionHandler(.NoData);
                return;
        }
    }
    
    // MARK: - Background Fetch
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        NSLog("Application will perform fetch in background !")
        if let vc = self.window?.rootViewController as? ViewController {
            vc.fetchUser({ () -> Void in
                completionHandler(.NewData)
                NSLog("Fetch handler action is done with new data !")
            })
        } else {
            completionHandler(.Failed)
            NSLog("Fetch handler action is done with fail !")
        }
    }
    
    // MARK: - Background Transfer Services
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        
    }

}

