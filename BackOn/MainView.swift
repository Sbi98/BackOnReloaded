//
//  ContentView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 10/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import CoreLocation

enum RequiredBy {
    case TaskViews
    case RequestViews
    case DiscoverableViews
    case AroundYouMap
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
                LoadingPageView().transition(.scale)
            } else {
                Text("Something's wrong, I can feel it")
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
            }
        }
    }
}
