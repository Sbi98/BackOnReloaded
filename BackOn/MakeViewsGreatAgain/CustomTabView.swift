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
        TabView (selection: $shared.selectedTab) {
            VStack {
                if shared.viewToShow == "HomeView" {
                    HomeView()
                } else if shared.viewToShow == "CommitmentDetailedView" {
                    CommitmentDetailedView(selectedCommitment: shared.selectedCommitment)
                } else if shared.viewToShow == "CommitmentsListView" {
                    CommitmentsListView()
                } else if shared.viewToShow == "AddNeedView" {
                    AddNeedView()
                } else if shared.viewToShow == "NeederHomeView" {
                    NeederHomeView()
                } else if shared.viewToShow == "NeedsListView" {
                    NeedsListView()
                } else if shared.viewToShow == "NeedDetailedView" {
                    NeedDetailedView(selectedCommitment: shared.selectedCommitment)
                } else {
                    Text("Vista sbagliata qui :(\n\(shared.viewToShow)")
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

