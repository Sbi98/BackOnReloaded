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
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    var selectedCommitment: Commitment?
    
    var body: some View {
        
        
                    ////OLD VERSION
        //            VStack {
        //                if shared.viewToShow != "FullDiscoverView"{
        //                ZStack {
        //                    MapView(selectedCommitment: selectedCommitment)
        //                        .statusBar(hidden: true)
        //                        .edgesIgnoringSafeArea(.all)
        //                        .frame(height: 515)
        //                    CloseButton()
        //                        .offset(x:173, y:-265)
        //                    }
        //                }
        //                HStack {
        //                    Spacer()
        //                    Button(action: {
        //                        let request = MKDirections.Request()
        //                        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.mapController.lastLocation!.coordinate))
        //                        let destination = MKMapItem(placemark: MKPlacemark(coordinate: self.selectedCommitment.position.coordinate))
        //                        destination.name = "\(self.selectedCommitment.userInfo.name)'s request: \(self.selectedCommitment.title)"
        //                        request.destination = destination
        //                        request.destination?.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
        //                    }, label: {
        //                        Text("Open in Maps").fontWeight(.light)})
        //                }.padding(.horizontal)
        //            }
        //            VStack (alignment: .leading, spacing: 10){
        //                // UserPreview(user: selectedCommitment.userInfo, description: selectedCommitment.etaText, whiteText: shared.darkMode)
        //                UserPreview(user: selectedCommitment.userInfo, description: mapController.lastLocation != nil ? selectedCommitment.etaText : "Location services disabled", whiteText: shared.darkMode)
        //                    .offset(x: 0, y: -10)
        //                Text(selectedCommitment.title)
        //                    .font(.headline)
        //                    .fontWeight(.regular)
        //                Text(selectedCommitment.descr)
        //                    .font(.subheadline)
        //                    .fontWeight(.light)
        //                    .bold()
        //                //                    .frame(width: .none, height: 60, alignment: .leading)
        //                Spacer()
        //                DoItButton()
        //            }.padding(.horizontal)
                    
        
        VStack(alignment: .leading) {
            if selectedCommitment != nil{
                VStack{
            HStack{
                Avatar(image: selectedCommitment!.userInfo.profilePic)
                VStack(alignment: .leading){
                    Text(selectedCommitment!.userInfo.identity).font(.headline).foregroundColor(.black)
                    Text(selectedCommitment!.title).font(.body).foregroundColor(.black)
                }.padding(.horizontal)
                Spacer()
                CloseButton(externalColor: #colorLiteral(red: 0.8717954159, green: 0.7912596464, blue: 0.6638498306, alpha: 1), internalColor: #colorLiteral(red: 0.4917932749, green: 0.4582487345, blue: 0.4234881997, alpha: 1))
                }.padding().background(Color(#colorLiteral(red: 0.9294117647, green: 0.8392156863, blue: 0.6901960784, alpha: 1))).cornerRadius(20, corners: [.topLeft, .topRight])
            
            Text(selectedCommitment!.descr).padding(.horizontal, 50)
            Divider().padding(.horizontal, 25)
            HStack(){
                Spacer()
                OpenInMapsButton(isFilled: false, selectedCommitment: selectedCommitment! ).padding(.horizontal)
                DoItButton().padding(.horizontal)
                Spacer()
            }
            Divider()
            Text("Qui ci va l'indirizzo")
            Divider()
            Text("Qui ci va la data")
            Spacer()
                }.onAppear{
            if self.mapController.lastLocation != nil {
                self.selectedCommitment!.requestETA(source: self.mapController.lastLocation!)
            }
        }
            } else{
            EmptyView()
        }
    }
    
   
    }
    
}


struct DiscoverDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverDetailedView(selectedCommitment: Commitment(userInfo: UserInfo(name: "Giancarlo", surname: "Sorrentino", email: "giancarlosorrentino99@gmail.com", photoURL: URL(string: "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3400&q=80")!, isHelper: 0), title: "Ho mal di testa", descr: "Ho bevuto troppo e sono in hangover, che posso farci? Devo andare in farmacia a prendere una moment ma non ho le forze.", date: Date(), position: CLLocation(latitude: 41, longitude: 15), ID: 2))
    }
}

extension View {
       func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
           clipShape( RoundedCorner(radius: radius, corners: corners) )
       }
   }

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
