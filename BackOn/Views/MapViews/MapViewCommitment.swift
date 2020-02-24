//
//  MapView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit

struct MapViewCommitment: UIViewRepresentable {
    @EnvironmentObject var shared: Shared
    
    var key: Int
    private static var mapViewStore = [Int : MKMapView]()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewCommitment

        init(_ parent: MapViewCommitment) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIScreen.main.traitCollection.userInterfaceStyle != .dark ? #colorLiteral(red: 0, green: 0.6529515386, blue: 1, alpha: 1) : #colorLiteral(red: 0.2057153285, green: 0.5236110687, blue: 0.8851857781, alpha: 1)
            renderer.lineWidth = 6.0
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view: MKAnnotationView
            if !annotation.isKind(of: MKUserLocation.self) {
               view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            } else {
                return nil
            }
            view.canShowCallout = false
            view.displayPriority = .required
            return view
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        if let mapView = MapViewCommitment.mapViewStore[key] {
           return mapView
        }
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        MapViewCommitment.mapViewStore[key] = mapView
//        print(mapView)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let commitment = shared.commitmentSet[key]
        if commitment != nil {
            let count = uiView.isUserLocationVisible ? 2:1 //https://stackoverflow.com/questions/51010956/how-can-i-know-if-an-annotation-is-already-on-the-mapview
            if uiView.annotations.count < count {
                let annotation = MKPointAnnotation()
                annotation.title = commitment!.userInfo.name
                annotation.subtitle = commitment!.title
                annotation.coordinate = commitment!.position.coordinate
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), completionHandler: {(placemarks, error) in
                    if let e = error {
                        print("Reverse geocoder failed with error: " + e.localizedDescription)
                        return
                    } // place is an instance of CLPlacemark and has the encapsulated address
                    if let place = placemarks {
                        let pm = place[0]
                        commitment!.textAddress = self.address(pm)
                    } else {
                        print("Problem with the data received from geocoder")
                    }
                })
                uiView.addAnnotation(annotation)
            }
//            else{
//                uiView.removeOverlays(uiView.overlays)
//            }
            let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
            let region = MKCoordinateRegion(center: commitment!.position.coordinate, span: span)
            uiView.setRegion(region, animated: true)
        } else {
//            print(key.uuidString)
        }
    }
    
    private func address(_ p: CLPlacemark) -> String {
        var ret = ""
        if let n = p.name, let t = p.thoroughfare, n.contains(t) {
            ret = "\(n), "
        } else {
            if let n = p.name {
                ret = "\(n), "
            }
            if let t = p.thoroughfare {
                if let st = p.subThoroughfare {
                    ret = "\(ret)\(st) "
                }
                ret = "\(ret)\(t), "
            }
        }
        if let c = p.country {
            if let aa = p.administrativeArea {
                if let l = p.locality {
                    ret = "\(ret)\(l) "
                }
                ret = "\(ret)\(aa), "
            }
            ret = "\(ret)\(c)"
        }
        if let pc = p.postalCode {
            ret = "\(ret) - \(pc)"
        }
        return ret
    }
}
