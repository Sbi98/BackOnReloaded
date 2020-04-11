////
////  Certificates.swift
////  BackOn
////
////  Created by Vincenzo Riccio on 11/02/2020.
////  Copyright © 2020 Vincenzo Riccio. All rights reserved.
////
//
//import SwiftUI
//import MapKit
//
//struct NeedDetailedView: View {
//    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
//    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
//    @ObservedObject var selectedTask: Task
//    
//    var body: some View {
//        VStack {
//            VStack {
//                ZStack {
//                    MapView(mode: .RequestDetailedModal, selectedTask: selectedTask)
//                        .statusBar(hidden: true)
//                        .edgesIgnoringSafeArea(.all)
//                        .frame(height: 515)
//                    CloseButton()
//                        .offset(x:173, y:-265)
//                }
//                HStack {
//                    Text(self.shared.dateFormatter.string(from: self.selectedTask.date)).foregroundColor(Color.secondary)
//                    Spacer()
//                    Button(action: {
//                        let request = MKDirections.Request()
//                        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.mapController.lastLocation!.coordinate))
//                        let destination = MKMapItem(placemark: MKPlacemark(coordinate: self.selectedTask.position.coordinate))
//                        destination.name = "\(self.selectedTask.neederUser.name)'s request: \(self.selectedTask.title)"
//                        request.destination = destination
//                        request.destination?.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
//                        }, label: {
//                            Text("Open in Maps").fontWeight(.light)})
//                }.padding(.horizontal)
//            }
//            VStack (alignment: .leading, spacing: 10){
////                UserPreview(user: selectedTask.userInfo, description: selectedTask.etaText, whiteText: shared.darkMode)
//                UserPreview(user: selectedTask.neederUser, whiteText: self.darkMode)
//                    .offset(x: 0, y: -10)
//                Text(selectedTask.title)
//                    .font(.headline)
//                    .fontWeight(.regular)
//                Text(selectedTask.descr)
//                    .font(.subheadline)
//                    .fontWeight(.light)
//                    .bold()
////                    .frame(width: .none, height: 60, alignment: .leading)
//                Spacer()
//                DontNeedAnymoreButton()
//            }.padding()
//        }
//    }
//}
//
