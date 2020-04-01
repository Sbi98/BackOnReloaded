//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

//import SwiftUI
//import MapKit

/*
@State var rating = -1

HStack(alignment: .center, spacing: 10, content: {
    ForEach(0..<5){ i in
        Image(systemName: "star.fill")
            .resizable()
            .frame(width: 35, height: 35)
            .foregroundColor(self.rating < i ? .gray : .yellow)
            .onTapGesture {
                self.rating = i
        }
    }
})
*/

//struct DiscoverDetailedViewOLD: View {
//    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
//    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
//    var selectedCommitment: Commitment?
//
//    var body: some View {
//
//        if selectedCommitment != nil {
//        //OLD VERSION
//                    VStack {
//                        if shared.viewToShow != "FullDiscoverView"{
//                        ZStack {
//                            MapView(selectedCommitment: selectedCommitment)
//                                .statusBar(hidden: true)
//                                .edgesIgnoringSafeArea(.all)
//                                .frame(height: 515)
//                            CloseButton()
//                                .offset(x:173, y:-265)
//                            }
//                        }
//                        HStack {
//                            Spacer()
//                            Button(action: {
//                                let request = MKDirections.Request()
//                                request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.mapController.lastLocation!.coordinate))
//                                let destination = MKMapItem(placemark: MKPlacemark(coordinate: self.selectedCommitment.position.coordinate))
//                                destination.name = "\(self.selectedCommitment.userInfo.name)'s request: \(self.selectedCommitment.title)"
//                                request.destination = destination
//                                request.destination?.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
//                            }, label: {
//                                Text("Open in Maps").fontWeight(.light)})
//                        }.padding(.horizontal)
//                    }
//                    VStack (alignment: .leading, spacing: 10){
//                        // UserPreview(user: selectedCommitment.userInfo, description: selectedCommitment.etaText, whiteText: shared.darkMode)
//                        UserPreview(user: selectedCommitment.userInfo, description: mapController.lastLocation != nil ? selectedCommitment.etaText : "Location services disabled", whiteText: shared.darkMode)
//                            .offset(x: 0, y: -10)
//                        Text(selectedCommitment.title)
//                            .font(.headline)
//                            .fontWeight(.regular)
//                        Text(selectedCommitment.descr)
//                            .font(.subheadline)
//                            .fontWeight(.light)
//                            .bold()
//                        //                    .frame(width: .none, height: 60, alignment: .leading)
//                        Spacer()
//                        DoItButton()
//                    }.padding(.horizontal)
//        } else {
//            EmptyView()
//        }
//
//
//    }
//
//}
//
//
//struct DiscoverDetailedView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiscoverDetailedView(selectedCommitment: Commitment(userInfo: UserInfo(name: "Giancarlo", surname: "Sorrentino", email: "giancarlosorrentino99@gmail.com", photoURL: URL(string: "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3400&q=80")!, isHelper: 0), title: "Ho mal di testa", descr: "Ho bevuto troppo e sono in hangover, che posso farci? Devo andare in farmacia a prendere una moment ma non ho le forze.", date: Date(), position: CLLocation(latitude: 41, longitude: 15), id: 2))
//    }
//}

//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape( RoundedCorner(radius: radius, corners: corners) )
//    }
//}

//struct RoundedCorner: Shape {
//
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
