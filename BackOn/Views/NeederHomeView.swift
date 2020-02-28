//
//  HomeView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import CoreLocation
import GoogleSignIn

struct NeederHomeView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController

    var body: some View {
        RefreshableScrollView(height: 100, refreshing: self.$shared.loading){
            VStack(alignment: .leading){
                Text("Hi \(CoreDataController().getLoggedUser().1.name)!")
                    .font(.largeTitle)
                    .bold()
                    .fontWeight(.heavy)
                    .padding(20)
//                Button(action: {
//                    print("Logout!")
//                    GIDSignIn.sharedInstance()?.disconnect()
//                }) {
//                    Text("Logout")
//                        .bold()
//                        .foregroundColor(.black)
//                }
                NeedsRow()
                Spacer()
                AddNeedButton()
                Spacer()
            }.padding(.top, 40)
        }.background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
}

