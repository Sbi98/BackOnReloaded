//
//  Committment.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import CoreLocation
import MapKit

class Task: ObservableObject, CustomStringConvertible {
    let neederID: String
    let title: String
    let descr: String?
    let date: Date
    let position: CLLocation
    let _id: String
    var helperID: String?
    var helperReport: String?
    var neederReport: String?
    
    @Published var mapSnap: UIImage?
    @Published var etaText = "Calculating..."
    @Published var address = "Locating..."
    @Published var city = "Locating..."
    
    public var description: String {return "    Request  #\(_id)\n         of  #\(neederID)\naccepted by  #\(helperID ?? "nobody")\n"}
    
    init(neederID: String, helperID: String? = nil, title: String, descr: String? = nil, date: Date, latitude: Double, longitude: Double, _id: String, mapSnap: UIImage? = nil, address: String? = nil, city: String? = nil, helperReport: String? = nil, neederReport: String? = nil) {
        self.neederID = neederID
        self.helperID = helperID
        self.title = title
        self.descr = descr
        self.date = date
        self._id = _id
        self.mapSnap = mapSnap
        if address != nil { self.address = address! }
        if city != nil { self.city = city! }
        self.position = CLLocation(latitude: latitude, longitude: longitude)
        self.helperReport = helperReport
        self.neederReport = neederReport
    }
    
    func isReported(helperToReport: Bool) -> Bool{
        return helperToReport ? helperReport == nil : neederReport == nil
    }
    
    func isExpired() -> Bool {
        return date < Date()
    }
    
    func timeRemaining() -> TimeInterval {
        return date.timeIntervalSinceNow
    }
    
    func requestETA(source: CLLocation? = MapController.lastLocation) {
        guard let source = source else {print("Source can't be nil for requesting ETA");return}
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: position.coordinate))
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculateETA { (res, error) in
            guard error == nil, let res = res else {print("Error while getting ETA");return}
            let eta = res.expectedTravelTime
            let hour = eta>7200 ? "hrs" : "hr"
            if eta > 3600 {
                self.etaText = "\(Int(eta/3600)) \(hour) \(Int((Int(eta)%3600)/60)) min"
            } else {
                self.etaText = "\(Int(eta/60)) min walk"
            }
        }
    }
    
    func locate(action: @escaping () -> Void = {}) {
        MapController.coordinatesToAddress(self.position) { result, error in
            guard error == nil, let result = result else {action();return}
            self.address = result
            let splitted = result.split(separator: ",")
            if splitted.count == 4 { self.city = "\(splitted[1])"}
            if splitted.count == 5 { self.city = "\(splitted[2])"}
            action()
        }
    }
}
