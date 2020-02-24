//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit

struct DiscoverDetailedView: View {
    @EnvironmentObject var shared: Shared
    @ObservedObject var selectedCommitment: Commitment
    
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    MapViewDiscoverDetailed(key: selectedCommitment.ID)
                        .statusBar(hidden: true)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 515)
                    CloseButton()
                        .offset(x:173, y:-265)
                }
                HStack {
                    Spacer()
                    Button(action: {
                        let request = MKDirections.Request()
                        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.shared.locationManager.lastLocation!.coordinate))
                        let destination = MKMapItem(placemark: MKPlacemark(coordinate: self.selectedCommitment.position.coordinate))
                        destination.name = "\(self.selectedCommitment.userInfo.name)'s request: \(self.selectedCommitment.title)"
                        request.destination = destination
                        request.destination?.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
                    }, label: {
                        Text("Open in Maps").fontWeight(.light)})
                }.padding(.horizontal)
            }
            VStack (alignment: .leading, spacing: 10){
                // UserPreview(user: selectedCommitment.userInfo, description: selectedCommitment.etaText, whiteText: shared.darkMode)
                UserPreview(user: selectedCommitment.userInfo, description: shared.locationManager.lastLocation != nil ? selectedCommitment.etaText : "Location services disabled", whiteText: shared.darkMode)                          
                    .offset(x: 0, y: -10)
                Text(selectedCommitment.title)
                    .font(.headline)
                    .fontWeight(.regular)
                Text(selectedCommitment.descr)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .bold()
                //                    .frame(width: .none, height: 60, alignment: .leading)
                Spacer()
                DoItButton()
            }.padding(.horizontal)
        }.onAppear {
            if self.shared.locationManager.lastLocation != nil {
                self.selectedCommitment.requestETA(source: self.shared.locationManager.lastLocation!)
            }
        }
    }
}


//struct CommitmentDetailedView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommitmentDetailedView()
//    }
//}
