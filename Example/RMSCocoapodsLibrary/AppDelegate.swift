//
//  AppDelegate.swift
//  RMSCocoapodsLibrary
//
//  Created by sayeed545 on 11/10/2021.
//  Copyright (c) 2021 sayeed545. All rights reserved.
//

import UIKit
import RMSCocoapodsLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let rmsOAuth = RMSOAuth2(
        clientID:    "24srb04apnmiojprk37tjt1nup",
        clientSecret: "19q5c5jbprvsv30j66nnm7j4t5vlte3pfu516vkr1iiv8tpo38ng",
        authorizeUrl:   "https://api-auth-dev1.retailmerchantservices.net/oauth2/authorize",
        accessTokenUrl: "https://api-auth-dev1.retailmerchantservices.net/oauth2/token",
        responseType:   "code",
        baseURL: "https://api-terminal-dev1.retailmerchantservices.net"
//        clientID:    "3c65r36dinkd5n8fo4ud4829cn",
//        clientSecret: "13dpgtvgfnqsn43drq20tdlvttps5m44luha7hauj6d6djua8j7f",
//        authorizeUrl:   "https://api-auth-dev.retailmerchantservices.net/oauth2/authorize",
//        accessTokenUrl: "https://api-auth-dev.retailmerchantservices.net/oauth2/token",
//        responseType:   "code",
//        baseURL: "https://api-terminal-sandbox.retailmerchantservices.net"
    )
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        <#code#>
//    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        guard let url = URLContexts.first?.url else {
//            return
//        }
        //let editedURL = url.absoluteString.replacingOccurrences(of: "kepos://", with: "kepos://oauth-callback")
       RMSOAuth.handle(url: url)
        return true
    }


}

