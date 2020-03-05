//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit

struct CommitmentDetailedView: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    @ObservedObject var selectedCommitment: Commitment
    
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    MapView(mode: .TaskDetailedModal, selectedCommitment: selectedCommitment)
                        .statusBar(hidden: true)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 515)
                    CloseButton()
                        .offset(x:173, y:-265)
                }
                HStack {
                    Text(self.shared.dateFormatter.string(from: self.selectedCommitment.date)).foregroundColor(Color.secondary)
                    Spacer()
                    OpenInMapsButton(isFilled: true, selectedCommitment: selectedCommitment)
                }.padding(.horizontal)
            }
            VStack (alignment: .leading, spacing: 10){
                UserPreview(user: selectedCommitment.userInfo, description: mapController.lastLocation != nil ? selectedCommitment.etaText : "Location services disabled" , whiteText: self.darkMode)
                    .offset(x: 0, y: -10)
                Text(selectedCommitment.title)
                    .font(.headline)
                    .fontWeight(.regular)
                Text(selectedCommitment.descr)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .bold()
                Spacer()
                CantDoItButton()
            }.padding()
        }.onAppear {
            if self.mapController.lastLocation != nil {
                self.selectedCommitment.requestETA(source: self.mapController.lastLocation!)
            }
        }
    }
}
