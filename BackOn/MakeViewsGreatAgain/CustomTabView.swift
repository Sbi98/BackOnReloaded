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
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        TabView {
            VStack {
                if shared.activeView == "HomeView" {
                    HomeView()
                } else if shared.activeView == "TasksListView" {
                    TasksListView()
                } else if shared.activeView == "AddNeedView" {
                    AddNeedView()
                }
//                else if shared.viewToShow == "NeederHomeView" {
//                    NeederHomeView()
//                } else if shared.viewToShow == "NeedsListView" {
//                    NeedsListView()
//                }
                else {
                    Text("Vista sbagliata qui :(\n\(shared.activeView)")
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundColor(.primary)
                }
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("Tasks")
            }.tag(0)
            
            FullDiscoverView()
            .tabItem {
                Image(systemName: "list.dash")
                Text("Discover")
            }.tag(1)
        }
        .edgesIgnoringSafeArea(.top)
        .overlay(DiscoverSheetView())
    }
}

