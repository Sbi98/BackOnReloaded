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
//struct CommitmentDetailedView: View {
//    @ObservedObject var selectedTask: Task
//    
//    var body: some View {
//        VStack {
//            VStack {
//                ZStack {
////                    MapView(mode: .TaskDetailedModal, selectedTask: selectedTask)
////                        .statusBar(hidden: true)
////                        .edgesIgnoringSafeArea(.all)
////                        .frame(height: 515)
//                    CloseButton()
//                        .offset(x:173, y:-265)
//                }
//                HStack {
//                    Text(self.shared.dateFormatter.string(from: self.selectedTask.date)).foregroundColor(Color.secondary)
//                    Spacer()
//                    OpenInMapsButton(isFilled: true, selectedTask: selectedTask)
//                }.padding(.horizontal)
//            }
//            VStack (alignment: .leading, spacing: 10){
//                UserPreview(user: selectedTask.neederUser, description: mapController.lastLocation != nil ? selectedTask.etaText : "Location services disabled" , whiteText: self.darkMode)
//                    .offset(x: 0, y: -10)
//                Text(selectedTask.title)
//                    .font(.headline)
//                    .fontWeight(.regular)
//                Text(selectedTask.descr)
//                    .font(.subheadline)
//                    .fontWeight(.light)
//                    .bold()
//                Spacer()
//                CantDoItButton()
//            }.padding()
//        }.onAppear {
//            if self.mapController.lastLocation != nil {
//                self.selectedTask.requestETA(source: self.mapController.lastLocation!)
//            }
//        }
//    }
//}
