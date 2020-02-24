//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct NeedView: View {
    @ObservedObject var need: Commitment
    @EnvironmentObject var shared: Shared

    var body: some View {
        Button(action: {
            withAnimation {
                self.shared.selectedCommitment = self.need
                NeedDetailedView.show()
            }
        }) {
            VStack (alignment: .leading, spacing: 5){
                UserPreviewNeeder(user: need.userInfo, whiteText: shared.darkMode)
                Spacer()
                Text(need.title)
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                Text(need.descr)
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                Spacer()
                Text(self.shared.dateFormatter.string(from: self.need.date)).foregroundColor(Color.secondary).frame(width: 300, alignment: .trailing)
            }
            .padding(10)
            .padding(.leading, 5)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 330, height: 230)
        .background(Color.primary.colorInvert())
        .cornerRadius(10)
        .shadow(radius: 10)
        .onAppear(perform: {
            if self.shared.locationManager.lastLocation != nil {
                self.need.requestETA(source: self.shared.locationManager.lastLocation!)
            }
        })
    }
}


struct NeedsRow: View {
    @EnvironmentObject var shared: Shared

    var body: some View {
        VStack (alignment: .leading) {
            Button(action: {
                withAnimation {
                    NeedsListView.show()
                }
            }) {
                HStack {
                    Text("Your requests")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBlue))
                }.padding(.horizontal, 20)
            }.buttonStyle(PlainButtonStyle())

            if shared.needArray().isEmpty{
                Text("You have no needs")
                    .font(.headline)
                    .padding(.horizontal, 50)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(shared.needArray(), id: \.ID) { currentDiscover in
                            NeedView(need: currentDiscover).frame(width: 330, height: 230)
                        }
                    }.padding(20)
                }.offset(x: 0, y: -20)
            }
        }
    }
}

struct NeedsListView: View {
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Button(action: {withAnimation{NeederHomeView.show()}}) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.headline).foregroundColor(Color(UIColor.systemBlue))
                    Text("Your needs")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding(.leading, 5)
                    Spacer()
                }.padding([.top,.horizontal])
                }.buttonStyle(PlainButtonStyle())
            
            RefreshableScrollView(height: 80, refreshing: self.$shared.loading) {
                VStack (alignment: .center, spacing: 25){
                    ForEach(shared.needArray(), id: \.ID) { currentCommitment in
                        Button(action: {withAnimation{
                            self.shared.selectedCommitment = currentCommitment
                            NeedDetailedView.show()
                            }}) {
                                HStack {
                                    UserPreview(user: currentCommitment.userInfo, description: currentCommitment.title, whiteText: self.shared.darkMode)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemBlue))
                                }.padding(.horizontal, 15)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.top,20)
            }
            Spacer()
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
}




