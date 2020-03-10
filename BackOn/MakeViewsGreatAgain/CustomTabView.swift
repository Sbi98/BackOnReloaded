//
//  TabView.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 04/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI
import CoreLocation

struct CustomTabView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared //serve per notificare il cambiamento della activeView alla View
    
    var body: some View {
        TabView {
            Group {
                if HomeView.isActive() {
                    HomeView()
                } else if TasksListView.isActive() {
                    TasksListView()
                }
                else {
                    Text("Something's wrong in CustomTab, I can feel it.")
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundColor(.primary)
                }
            }
            .tabItem {
                Image(systemName: "rectangle.stack.fill.badge.person.crop").font(.title)
                Text("Tasks").font(.largeTitle)
            }.tag(0)
            
            FullDiscoverView()
                .accentColor(Color(.systemBlue))
                .tabItem {
                    Image("DiscoverTabButton")
                    Text("Discover").font(.largeTitle)
            }.tag(1)
        }.accentColor(Color(.systemOrange))
            .edgesIgnoringSafeArea(.top)
            .overlay(DiscoverSheetView())
    }
}
