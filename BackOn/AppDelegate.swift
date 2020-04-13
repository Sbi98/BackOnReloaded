//
//  AppDelegate.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 14/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData
import GoogleSignIn
import UserNotifications

typealias ErrorString = String
typealias RequestCategory = String
typealias Request = Task
typealias ExpiredRequest = Task
typealias Discoverable = Task

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate {
    let shared: Shared = Shared()
    let discoverTabController: DiscoverTabController = DiscoverTabController()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        CoreDataController.initController() //inizializza CoreDataController e recupera l'utente loggato
        MapController.initController() //avvia la localizzazione
        CalendarController.initController() //controlla i permessi del calendario
        if CoreDataController.loggedUser == nil {
            shared.mainWindow = "LoginPageView"
        } else {
            CoreDataController.loadInShared()
            DatabaseController.loadFromServer()
        }
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize sign-in
        GIDSignIn.sharedInstance()?.clientID = "571455866380-8d58drp1d8ap0bkh3tc1c7b29arrfr5c.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        registerForPushNotifications()
        return true
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        CoreDataController.saveDeviceToken(deviceToken: token == "" ? nil : token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard error == nil && granted else { print("Permission for push notifications not granted!"); return }
            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        }
    }
    
    //Metodo di accesso
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {print("Sign error"); return}
        DispatchQueue.main.async { self.shared.mainWindow = "LoadingPageView" }
        // Perform any operations on signed in user here.
        //let userid = user.userid                  // For client-side use only!
        //let idToken = user.authentication._idToken // Safe to send to the server
        //      Aggiungo al DB e a Coredata
        DatabaseController.signUp(
            name: user.profile.givenName!,
            surname: user.profile.familyName,
            email: user.profile.email!,
            photoURL: user.profile.imageURL(withDimension: 200)!
        ){ loggedUser, error in
            guard error == nil, let loggedUser = loggedUser else {print("Error with Google SignUp");return} //FAI L'ALERT!
            CoreDataController.signUp(user: loggedUser)
            DispatchQueue.main.async { self.shared.mainWindow = "CustomTabView" }
            DatabaseController.loadFromServer()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        print("\n*** User signed out from Google ***\n")
        CoreDataController.deleteLoggedUser()
        DispatchQueue.main.async { self.shared.mainWindow = "LoginPageView" }
    }
    
}

