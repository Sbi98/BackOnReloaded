//
//  ContentView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 10/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import CoreLocation

extension View {
    var darkMode: Bool {
        get {
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark
        }
    }
    
//    func showSheet<Content>(isPresented: Binding<Bool>, content: Content) where Content: View {
//        self.sheet(isPresented: isPresented, content: {content})
//    }
    
    static func show() {
        let shared = (UIApplication.shared.delegate as! AppDelegate).shared
        shared.previousView = shared.viewToShow
        shared.viewToShow = String(describing: self)
    }
}


struct MainView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    @ObservedObject var mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    
    var body: some View {
        VStack{
            if shared.mainWindow == "CustomTabView" {
                CustomTabView()
            } else if shared.mainWindow == "LoginPageView" {
                LoginPageView()
            } else if shared.mainWindow == "LoadingPageView" {
                LoadingPageView().transition(.scale)
            } else {
                Text("Vista sbagliata :(")
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
            }
        }
        .alert(isPresented: $mapController.showLocationAlert){locAlert}
    }
}
