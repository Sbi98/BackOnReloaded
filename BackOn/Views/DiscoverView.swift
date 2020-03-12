//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

//import SwiftUI
//import CoreLocation
//import MapKit
//
//struct DiscoverView: View {
//    @ObservedObject var commitment: Commitment
//    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
//    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
//    
//    var body: some View {
//        Button(action: {
//            withAnimation {
//                self.shared.selectedCommitment = self.commitment
//                DiscoverDetailedView.show()
//            }
//        }) {
//            VStack (alignment: .leading, spacing: 5){
//                UserPreview(user: commitment.userInfo, description: mapController.lastLocation != nil ? commitment.etaText : "Location services disabled", whiteText: self.darkMode)
//                Text(commitment.title)
//                    .font(.headline)
//                    .fontWeight(.regular)
//                    .foregroundColor(.primary)
//                    .padding(.top, 20)
//                Text(commitment.descr)
//                    .font(.subheadline)
//                    .fontWeight(.light)
//                    .bold()
//                    .foregroundColor(.black)
//                    .frame(width: .none, height: 60, alignment: .leading)
//            }.padding(.horizontal, 20)
//                .offset(x: 0, y: -10)
//                .frame(width: 320, height: 230)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .frame(width: 320, height: 230)
//        .background(Color.primary.colorInvert())
//        .cornerRadius(10)
//        .shadow(radius: 10)
//        .onAppear(perform: {
//            if self.mapController.lastLocation != nil {
//                self.commitment.requestETA(source: self.mapController.lastLocation!)
//            }
//        })
//    }
//}
//
//
//struct DiscoverRow: View {
//    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
//    
//    var body: some View {
//        VStack (alignment: .leading) {
//            Button(action: {
//                withAnimation {
//                    FullDiscoverView.show()
//                }
//            }) {
//                HStack {
//                    Text("Around you")
//                        .fontWeight(.bold)
//                        .font(.title)
//                    Spacer()
//                    Image(systemName: "chevron.right")
//                        .font(.headline)
//                        .foregroundColor(Color(UIColor.systemBlue))
//                }.padding(.horizontal, 20)
//            }.buttonStyle(PlainButtonStyle())
//            
//            if shared.discoverArray().isEmpty{
//                Text("There are no needers in your surroundings").font(.headline)
//                    .padding(.horizontal, 50)
//            } else{
//                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 20) {
//                        ForEach(shared.discoverArray(), id: \.ID) { currentDiscover in
//                            DiscoverView(commitment: currentDiscover).frame(width: 320, height: 230)
//                        }
//                    }.padding(20)
//                }.offset(x: 0, y: -20)
//            }
//        }
//    }
//}


//struct FullDiscoverView: View {
//    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
//    @ObservedObject var mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
//    @State var showDetailedModal: Bool = false
//
//    var body: some View {
//        VStack (alignment: .leading, spacing: 10){
//            Button(action: {
//                withAnimation{
//                    HomeView.show()
//                }}){
//                    HStack {
//                        Text("Around you")
//                            .fontWeight(.bold)
//                            .font(.title).foregroundColor(.primary)
//                    }.padding([.top,.horizontal])
//            }
//
//            Picker(selection: $shared.fullDiscoverViewMode, label: Text("Select")) {
//                Text("List").tag(1)
//                Text("Map").tag(0)
//            }.pickerStyle(SegmentedPickerStyle()).labelsHidden().padding(.horizontal)
//            if shared.fullDiscoverViewMode == 1 {
//                VStack (alignment: .center, spacing: 25){
//                    ForEach(shared.discoverArray(), id: \.ID) { currentDiscover in
//                        Button(action: {
//                            self.shared.selectedCommitment = currentDiscover
//                            DiscoverDetailedView.show()
//                        }) {
//                            HStack {
//                                UserPreview(user: currentDiscover.userInfo, description: "\(currentDiscover.title)", whiteText: self.darkMode)
//                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .font(.headline)
//                                    .foregroundColor(Color(UIColor.systemBlue))
//                            }.padding(.horizontal, 15)
//                        }.buttonStyle(PlainButtonStyle())
//                    }
//                }.padding(.top,20)
//            } else {
//                MapView().cornerRadius(20)
//            }
//        }
//        .padding(.top, 40)
//        .background(Color.primary.colorInvert())
//        .edgesIgnoringSafeArea(.all)
//
//    }
//}



