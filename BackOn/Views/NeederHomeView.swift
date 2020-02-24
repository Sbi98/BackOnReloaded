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
    @ObservedObject var  shared = (UIApplication.shared.delegate as! AppDelegate).shared
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

//struct NeederCommitRow: View {
//    @EnvironmentObject var shared: Shared
//
//    var body: some View {
//        VStack (alignment: .leading) {
//            Button(action: {
//                withAnimation {
//                    FullDiscoverView.show()
//                }
//            }) {
//                HStack {
//                    Text("Your requests")
//
//                        //Text("Around you")
//                        .fontWeight(.bold)
//                        .font(.title)
//                    Spacer()
//                    Image(systemName: "chevron.right")
//                        .font(.headline)
//                        .foregroundColor(Color(UIColor.systemBlue))
//                }.padding(.horizontal, 20)
//            }.buttonStyle(PlainButtonStyle())
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 20) {
//                    ForEach(shared.commitmentArray(), id: \.ID) { currentDiscover in
//                        DiscoverView(commitment: currentDiscover)
//                    }
//                }.padding(20)
//            }.offset(x: 0, y: -20)
//        }
//    }
//}
