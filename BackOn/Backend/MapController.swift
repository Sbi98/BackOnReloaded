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
    
    
    func coordinatesToAddress(location: CLLocation = (UIApplication.shared.delegate as! AppDelegate).mapController.lastLocation!, completion: @escaping (String)-> Void) {
        CLGeocoder().reverseGeocodeLocation(location) {(placemarks, error) in
            guard error == nil, let p = placemarks?.first else {print("Reverse geocoder failed"); return}
            completion(self.extractAddress(p))
        }
    }
    
    func addressToCoordinates(address: String, completion: @escaping (CLLocationCoordinate2D)-> Void) {
        CLGeocoder().geocodeAddressString(address) {(placemarks, error) in
            guard error == nil else {return}
            if let placemark = placemarks?.first {
                completion(placemark.location!.coordinate)
            }
        }
    }
    
    private func extractAddress(_ p: CLPlacemark) -> String {
        var address = ""
        if let streetInfo1 = p.thoroughfare {
            address = "\(address)\(streetInfo1), "
        }
        if let streetInfo2 = p.subThoroughfare {
            address = "\(address)\(streetInfo2), "
        }
        if let locality = p.locality {
            address = "\(address)\(locality), "
        }
        if let postalCode = p.postalCode {
            address = "\(address)\(postalCode), "
        }
        if let country = p.country {
            address = "\(address)\(country)"
        }
        return address
    }
    
    func openInMaps(commitment: Commitment){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.lastLocation!.coordinate))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: commitment.position.coordinate))
        destination.name = "\(commitment.userInfo.name)'s request: \(commitment.title)"
        request.destination = destination
        request.destination?.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }

}

