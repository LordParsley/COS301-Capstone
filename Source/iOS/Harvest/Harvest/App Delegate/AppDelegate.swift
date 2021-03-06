//
//  AppDelegate.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/03/26.
//  Copyright © 2018 University of Pretoria. All rights reserved.
//

import Disk
import FirebaseDatabase
import FirebaseCore
import GoogleMaps
import GoogleSignIn
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    if let id = Bundle.main.bundleIdentifier {
//      UserDefaults.standard.removePersistentDomain(forName: id)
//    }
    
    GMSServices.provideAPIKey("AIzaSyCqLn8RGeR84StTCIA1uvoO_iWGhXw8vAU")
    FirebaseApp.configure()
    
    Database.database().isPersistenceEnabled = true
    
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    
    return true
  }
  
  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return GIDSignIn
      .sharedInstance()
      .handle(
        url,
        sourceApplication:
        options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: [:])
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the
    // application and it begins the transition to the background state. Use
    // this method to pause ongoing tasks, disable timers, and invalidate
    // graphics rendering callbacks. Games should use this method to pause the
    // game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
    
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state;
    // here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
    
    #if !DEBUG
      TrackerViewController.tracker?.storeSession()
    #endif
  }
  
  func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    return UIDevice.current.userInterfaceIdiom == .phone
      ? .allButUpsideDown
      : .all
  }
}
