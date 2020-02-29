//
//  AppView.swift
//  BackOn
//
//  Created by Giancarlo Sorrentino on 29/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

struct AppView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    var body: some View {
        VStack{
            if shared.viewToShow != "LoginPageView" && shared.viewToShow != "LoadingPageView"{
                TabView{
                    ContentView().tabItem{
                        Image(systemName: "list.dash")
                    }
                }.edgesIgnoringSafeArea(.top)
            }
            else{
                ContentView()
                }
        }.overlay(DiscoverSheetView(isOpen: $shared.showDetailed, maxHeight: CGFloat(UIScreen.main.bounds.height - 10), content: {
            DiscoverDetailedView(selectedCommitment: shared.selectedCommitment)
        }).edgesIgnoringSafeArea(.bottom))
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
