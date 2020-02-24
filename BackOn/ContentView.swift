//
//  ContentView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 10/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

extension View {
    static func show() {
        let shared = (UIApplication.shared.delegate as! AppDelegate).shared
        shared.previousView = shared.viewToShow
        shared.viewToShow = String(describing: self)
    }
}

struct ContentView: View {
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        VStack{
            if shared.viewToShow == "HomeView" {
                HomeView()
            } else if shared.viewToShow == "LoginPageView"{
                LoginPageView()
            } else if shared.viewToShow == "CommitmentDetailedView"{
                CommitmentDetailedView(selectedCommitment: shared.selectedCommitment)
            } else if shared.viewToShow == "DiscoverDetailedView"{
                DiscoverDetailedView(selectedCommitment: shared.selectedCommitment)
            } else if shared.viewToShow == "CommitmentsListView"{
                CommitmentsListView()
            } else if shared.viewToShow == "AddNeedView"{
                AddNeedView()
            } else if shared.viewToShow == "NeederHomeView"{
                NeederHomeView()
            } else if shared.viewToShow == "FullDiscoverView"{
                FullDiscoverView()
            } else if shared.viewToShow == "NeedsListView"{
                NeedsListView()
            } else if shared.viewToShow == "LoadingPageView" {
                LoadingPageView().transition(.scale)
            } else if shared.viewToShow == "NeedDetailedView" {
                NeedDetailedView(selectedCommitment: shared.selectedCommitment)
            }
            else {
                Text("Vista sbagliata :(")
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
            }
        }
        .alert(isPresented: $shared.locationManager.showAlert){locAlert}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

