import CoreLocation
import MapKit
import SwiftUI

class MapController {
    private static let locationManager = CLLocationManager()
    private static let delegate = LocationManagerDelegate(action: updateLocation(lastLocation:))
    static var lastLocation: CLLocation?
    
    static func initController() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = delegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    static func getSnapshot(location: CLLocationCoordinate2D, width: CGFloat = 320, height: CGFloat = 350, completion: @escaping (MKMapSnapshotter.Snapshot?, String?)-> Void) { //(snapshot, error) -> Void
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: mapSpan)
        mapSnapshotOptions.region = region
        mapSnapshotOptions.size = CGSize(width: width, height: height)
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start { (snapshot:MKMapSnapshotter.Snapshot?, error:Error?) in
            completion(snapshot,error?.localizedDescription)
        }
    }
    
    static func coordinatesToAddress(_ location: CLLocation?, completion: @escaping (String?, String?)-> Void) { //(address, error) -> Void
        var toConvert = location
        if toConvert == nil {
            toConvert = lastLocation
            if toConvert == nil {
                completion(nil,"Location access not granted")
                return
            }
        }
        CLGeocoder().reverseGeocodeLocation(toConvert!) {(placemarks, error) in
            guard error == nil, let p = placemarks?.first else {completion(nil,"Reverse geocoder failed"); return}
            completion(self.extractAddress(p),nil)
        }
    }
    
    static func addressToCoordinates(_ address: String, completion: @escaping (CLLocationCoordinate2D?, String?)-> Void) { //(coordinates, error) -> Void
        CLGeocoder().geocodeAddressString(address) {(placemarks, error) in
            guard error == nil, let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate else {completion(nil,"Geocoder failed"); return}
            completion(coordinate,nil)
        }
    }
    
    static func openInMaps(commitment: Task) {
        let request = MKDirections.Request()
        if lastLocation != nil {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation!.coordinate))
        }
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: commitment.position.coordinate))
        destination.name = "\(commitment.neederUser.name)'s request: \(commitment.title)"
        request.destination = destination
        request.destination?.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }
    
    static private func updateLocation(lastLocation: CLLocation) {
        let shared = (UIApplication.shared.delegate as! AppDelegate).shared
        self.lastLocation = lastLocation
        if lastLocation.horizontalAccuracy < 35.0 {
            locationManager.stopUpdatingLocation()
            shared.requestETA()
        }
    }
    
    static private func extractAddress(_ p: CLPlacemark) -> String {
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
}

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var action: (CLLocation) -> Void
    
    init(action: @escaping (CLLocation) -> Void) {
        self.action = action
        super.init()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        action(location)
    }
}

