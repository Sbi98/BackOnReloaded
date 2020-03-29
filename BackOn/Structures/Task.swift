//
//  Committment.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import CoreLocation
import MapKit

class Task: ObservableObject, CustomStringConvertible { //ho tolto che estende NSObject, mi sembra servisse solo per una cosa di COreData
    let neederID: String
    let title: String
    let descr: String?
    let date: Date
    let position: CLLocation
    let _id: String
    var helperID: String?
    @Published var mapSnap: UIImage?
    @Published var etaText = "Calculating..."
    @Published var address = "Locating..."
    @Published var city = "Locating..."
    
    public var description: String {return "Request      #\(_id)\n          of #\(neederID)\n accepted by #\(helperID ?? "nobody")\n"}
    
    init(neederID: String, title: String, descr: String?, date: Date, latitude: Double, longitude: Double, _id: String) {
        self.neederID = neederID
        self.title = title
        self.descr = descr
        self.date = date
        self._id = _id
        self.position = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    init(neederID: String, helperID: String?, title: String, descr: String?, date: Date, latitude: Double, longitude: Double, _id: String) {
        self.neederID = neederID
        self.helperID = helperID
        self.title = title
        self.descr = descr
        self.date = date
        self._id = _id
        self.position = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func isExpired() -> Bool {
        return date < Date()
    }
    
    func timeRemaining() -> TimeInterval {
        return date.timeIntervalSinceNow
    }
    
    func requestETA(source: CLLocation) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: position.coordinate))
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculateETA { (res, error) in
            guard error == nil else {print("Error while getting ETA");return}
            let eta = res!.expectedTravelTime
            let hour = eta>7200 ? "hrs" : "hr"
            if eta > 3600 {
                self.etaText = "\(Int(eta/3600)) \(hour) \(Int((Int(eta)%3600)/60)) min"
            } else {
                self.etaText = "\(Int(eta/60)) min walk"
            }
        }
    }
    
    func locate() {
        MapController.coordinatesToAddress(self.position) { result, error in
            guard error == nil, let result = result else {return}
            self.address = result
            let splitted = result.split(separator: ",")
            if splitted.count >= 3 { self.city = "\(splitted[2])" }
        }
    }
}

//  Questo metodo da un array di commitment restituisce il più imminente assumendo che:
func getNextCommitment(dataDictionary: [Int:Task]) -> Task? {
    if(dataDictionary.count == 0){
        return nil
    }
    let data = Array(dataDictionary.values)
    var toReturn = data[0]
    for c in data {
        if toReturn.date.compare(c.date) == ComparisonResult.orderedDescending {
            toReturn = c
        }
    }
    return toReturn
}

func getNextNotificableCommitment(dataDictionary: [Int:Task]) -> Task? {
    if(dataDictionary.count == 0){
        return nil
    }
    var data = Array(dataDictionary.values)
    var toReturn: Task?
    repeat{
        let i = data.removeFirst()
        if(i.timeRemaining() > TimeInterval(30*60)){
            toReturn = toReturn == nil ? i : toReturn
            if(toReturn!.timeRemaining() > i.timeRemaining()){
                toReturn = i
            }
        }} while data.count>0
    return toReturn
}

func getNextFive(dataDictionary: [Int: Task]) -> [Task]{
    let data = Array(dataDictionary.values)
    var toReturn: [Task] = [data[0]]
    //   Mi serve a sapere se non ho ancora inserito i primi 5 elementi ordinatamente
    var last = 0
    
    for i in 1...data.count {
        for j in stride(from: last < 5 ? last : 4, through: 0, by: -1) {
            if toReturn[j].date.compare(data[i].date) == ComparisonResult.orderedDescending{
                let toShift = toReturn[j]
                toReturn[j] = data[i]
                toReturn[j + 1] = toShift
            } else {
                if last < 5 {
                    toReturn[last + 1] = data[i]
                }
            }
            last += 1
        }
    }
    return toReturn
}
