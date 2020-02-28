import Foundation
import CoreLocation
import MapKit
import SwiftUI

class MapController: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var showLocationAlert = true
    var lastLocation: CLLocation?
    @Published var showCallout = false
    
    override init() {
        super.init()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            showLocationAlert = false
        default:
            showLocationAlert = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
    }
    
    func locationAsAddress(location: CLLocation = (UIApplication.shared.delegate as! AppDelegate).mapController.lastLocation!, completion: @escaping (String)-> Void) {
        CLGeocoder().reverseGeocodeLocation(location) {(placemarks, error) in
            guard error == nil && placemarks != nil else {print("Reverse geocoder failed"); return}
            let p = placemarks![0]
            completion("\(p.thoroughfare!), \(p.locality!), \(p.postalCode!), \(p.country!)")
        }
    }
    
    private func extractAddress(_ p: CLPlacemark) -> String { //mai usata
        var ret = ""
        if let n = p.name, let t = p.thoroughfare, n.contains(t) {
            ret = "\(n), "
        } else {
            if let n = p.name {
                ret = "\(n), "
            }
            if let t = p.thoroughfare {
                if let st = p.subThoroughfare {
                    ret = "\(ret)\(st), "
                }
                ret = "\(ret)\(t), "
            }
        }
        if let c = p.country {
            if let l = p.locality {
                ret = "\(ret)\(l), "
                if let pc = p.postalCode {
                    ret = "\(ret)\(pc), "
                }
            }
            ret = "\(ret)\(c)"
        }
        return ret
    }
    
}
