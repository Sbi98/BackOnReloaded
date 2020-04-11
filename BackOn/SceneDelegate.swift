//
//  SceneDelegate.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 10/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import UIKit
import SwiftUI

enum RequiredBy {
    case TaskViews
    case RequestViews
    case DiscoverableViews
    case AroundYouMap
}

class CustomHostingController<Content:View>: UIHostingController<AnyView> {
    let hideStatusBar: Bool
    
    init(contentView: Content, hideStatusBar: Bool = false, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) {
        self.hideStatusBar = hideStatusBar
        super.init(rootView: AnyView(EmptyView()))
        self.modalPresentationStyle = modalPresentationStyle
        self.rootView = AnyView(contentView.environmentObject(ViewControllerHolder(self)))
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
}

class ViewControllerHolder: ObservableObject {
    var value: UIViewController
    init(_ viewController: UIViewController) {
        self.value = viewController
    }
}

extension UIViewController {
    func presentView<Content: View>(_ viewToPresent: Content, hideStatusBar: Bool = false, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) {
        self.present(CustomHostingController(contentView: viewToPresent, hideStatusBar: hideStatusBar, modalPresentationStyle: modalPresentationStyle), animated: true, completion: nil)
    }
}

extension View {
    var darkMode: Bool {
        get {
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark
        }
    }
    func myoverlay<Content:View>(isPresented: Binding<Bool>, toOverlay: Content) -> some View {
        return self.overlay(myOverlay(isPresented: isPresented, toOverlay: AnyView(toOverlay)))
    }
    static func show() {
        (UIApplication.shared.delegate as! AppDelegate).shared.activeView = String(describing: self)
    }
    static func isActive() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).shared.activeView == String(describing: self)
    }
    static func isMainWindow() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).shared.mainWindow == String(describing: self)
    }
}

struct MainView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared //serve per notificare il cambiamento della mainWindow alla View
    var body: some View {
        Group {
            if CustomTabView.isMainWindow() {
                CustomTabView()
            } else if LoginPageView.isMainWindow() {
                LoginPageView()
             } else if LoadingPageView.isMainWindow() {
                LoadingPageView()
             } else {
                Text("Something's wrong, I can feel it").font(.title).foregroundColor(.primary)
            }
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var isReadyToUpdate = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Get the managed object context from the shared persistent container.
        // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = CustomHostingController(contentView: MainView())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        guard isReadyToUpdate else {return}
        DatabaseController.loadFromServer()
        isReadyToUpdate = false
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        // Save changes in the application's managed object context when the application transitions to the background.
        //(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        guard CoreDataController.loggedUser != nil else {return}
        print("*** Svuoto i dizionari Discover ***")
        (UIApplication.shared.delegate as! AppDelegate).shared.myDiscoverables = [:]
        (UIApplication.shared.delegate as! AppDelegate).shared.discUsers = [:]
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        guard scene.activationState == .background && CoreDataController.loggedUser != nil else {return}
        isReadyToUpdate = true
    }

}


// Chiedo l'autorizzazione per le notifiche di tipo ALERT, BADGE E NOTIFICATION SOUND
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
//            if success {
//                print("Notification permission set!")
//            } else if let error = error {
//                print(error.localizedDescription)
//            }
//        }
