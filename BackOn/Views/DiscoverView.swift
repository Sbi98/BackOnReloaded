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

struct DiscoverView: View {
    @ObservedObject var commitment: Commitment
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.shared.selectedCommitment = self.commitment
                DiscoverDetailedView.show()
            }
        }) {
            VStack (alignment: .leading, spacing: 5){
                UserPreview(user: commitment.userInfo, description: shared.locationManager.lastLocation != nil ? commitment.etaText : "Location services disabled", whiteText: shared.darkMode)
                Text(commitment.title)
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                Text(commitment.descr)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .bold()
                    .foregroundColor(.black)
                    .frame(width: .none, height: 60, alignment: .leading)
            }.padding(.horizontal, 20)
                .offset(x: 0, y: -10)
                .frame(width: 320, height: 230)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 320, height: 230)
        .background(Color.primary.colorInvert())
        .cornerRadius(10)
        .shadow(radius: 10)
        .onAppear(perform: {
            if self.shared.locationManager.lastLocation != nil {
                self.commitment.requestETA(source: self.shared.locationManager.lastLocation!)
            }
        })
    }
}


struct DiscoverRow: View {
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        VStack (alignment: .leading) {
            Button(action: {
                withAnimation {
                    FullDiscoverView.show()
                }
            }) {
                HStack {
                    Text("Around you")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBlue))
                }.padding(.horizontal, 20)
            }.buttonStyle(PlainButtonStyle())
            
            if shared.discoverArray().isEmpty{
                Text("There are no needers in your surroundings").font(.headline)
                    .padding(.horizontal, 50)
            } else{
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(shared.discoverArray(), id: \.ID) { currentDiscover in
                            DiscoverView(commitment: currentDiscover).frame(width: 320, height: 230)
                        }
                    }.padding(20)
                }.offset(x: 0, y: -20)
            }
        }
    }
}


struct FullDiscoverView: View {
    @EnvironmentObject var shared: Shared
    @State private var selectedView = 0
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Button(action: {
                withAnimation{
                    HomeView.show()
                }}){
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)
                        
                        Text("Around you")
                            .fontWeight(.bold)
                            .font(.title).foregroundColor(.primary)
                    }.padding([.top,.horizontal])
            }
            
            Picker(selection: $selectedView, label: Text("What is your favorite color?")) {
                Text("List").tag(0)
                Text("Map").tag(1)
            }.pickerStyle(SegmentedPickerStyle()).labelsHidden().padding(.horizontal)
            if selectedView == 0 {RefreshableScrollView(height: 70, refreshing: self.$shared.loading) {
                VStack (alignment: .center, spacing: 25){
                    ForEach(shared.discoverArray(), id: \.ID) { currentDiscover in
                        Button(action: {
                            self.shared.selectedCommitment = currentDiscover
                            DiscoverDetailedView.show()
                        }) {
                            HStack {
                                UserPreview(user: currentDiscover.userInfo, description: "\(currentDiscover.title)\nCasa", whiteText: self.shared.darkMode)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.systemBlue))
                            }.padding(.horizontal, 15)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.top,20)
                }
            }
            else{
                MapViewDiscover().cornerRadius(20)
            }
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
}



