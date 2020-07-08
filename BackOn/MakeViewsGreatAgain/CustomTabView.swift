//
//  TabView.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 04/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
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
                } else if RequestsListView.isActive() {
                    RequestsListView()
                } else {
                    Text("Something's wrong in CustomTab, I can feel it.")
                        .font(.title)
                        .foregroundColor(.primary)
                }
            }
            .tabItem {
                Image(systemName: "rectangle.stack.fill.badge.person.crop").font(.title)
                Text("About you").font(.largeTitle)
            }.tag(0)
            
            FullDiscoverView()
                .accentColor(Color(.systemBlue))
                .tabItem {
                    Image("DiscoverSymbol").font(.largeTitle)
                    Text("Discover").font(.largeTitle)
                }.tag(1)
        }
        .accentColor(Color(.systemOrange))
        .overlay(DiscoverSheetView())
    }
}
