//
//  AppDelegate.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 14/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData
import GoogleSignIn
import UserNotifications

typealias ErrorString = String
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
        GIDSignIn.sharedInstance()?.clientID = "445586099169-q07rg5bbaa4p5ajhe3gfitikj35ige1h.apps.googleusercontent.com"
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
    
    func registerForPushNotifications() {
              UNUserNotificationCenter.current().delegate = self
              UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                  (granted, error) in
                  print("Permission granted: \(granted)")
                  // 1. Check if permission granted
                  guard granted else { return }
                  // 2. Attempt registration for remote notifications on the main thread
                  DispatchQueue.main.async {
                      UIApplication.shared.registerForRemoteNotifications()
                  }
              }
          }
       
       func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           // 1. Convert device token to string
           let tokenParts = deviceToken.map { data -> String in
               return String(format: "%02.2hhx", data)
           }
           let token = tokenParts.joined()
           // 2. Print device token to use for PNs payloads
           print("Device Token: \(token)")
       }

       func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           // 1. Print out error if PNs registration not successful
           print("Failed to register for remote notifications with error: \(error)")
       }
    
    /*
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "BackOn")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    */
}

