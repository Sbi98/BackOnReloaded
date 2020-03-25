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

typealias ErrorString = String

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    let shared: Shared
    let discoverTabController: DiscoverTabController
    
    override init() {
        shared = Shared()
        discoverTabController = DiscoverTabController()
        super.init()
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MapController.initController()
        CalendarController.initController() //controlla i permessi del calendario
        CoreDataController.initController() //Qui se l'utente non ha fatto l'accesso imposta la LoginPageView
        return true
    }
    
    //Metodo di accesso
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {print("Sign error"); return}
        // Perform any operations on signed in user here.
        //let userid = user.userid                  // For client-side use only!
        //let idToken = user.authentication._idToken // Safe to send to the server
        
        //      Aggiungo al DB e a Coredata
        DatabaseController.signUp(name: user.profile.givenName!, surname: user.profile.familyName, email: user.profile.email!, photoURL: user.profile.imageURL(withDimension: 100)!){ loggedUser, error in
            guard error == nil  && loggedUser != nil else {return} //FAI L'ALERT!
            DispatchQueue.main.async {
                CoreDataController.signup(user: loggedUser!)
                print(CoreDataController.loggedUser!._id)
                DatabaseController.getMyTasks(){ tasks, users, error in
                    guard error == nil  && tasks != nil && users != nil else {return} //FAI L'ALERT!
                    DispatchQueue.main.async {
                        for task in tasks!{
                            self.shared.myTasks[task._id] = task
                        }
                        for user in users!{
                            self.shared.users[user._id] = user
                        }
                    }
                }
                DatabaseController.getMyRequests(){ requests, users, error in
                    guard error == nil  && requests != nil && users != nil else {return} //FAI L'ALERT!
                    DispatchQueue.main.async {
                        for request in requests!{
                            self.shared.myRequests[request._id] = request
                        }
                        for user in users!{
                            self.shared.users[user._id] = user
                        }
                    }
                }
            }
            
            
        }
        
        
        //        CoreDataController.addUser(user: User(name: "Giancarlo", surname: "Sorrentino", email: "prova", photoURL: URL(string: "prova")!))
        shared.mainWindow = "LoadingPageView"
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        print("\n*** User signed out from Google ***\n")
        guard let loggedUser = CoreDataController.loggedUser else {return}
        CoreDataController.deleteUser(user: loggedUser)
        shared.mainWindow = "LoginPageView"
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
    
}

