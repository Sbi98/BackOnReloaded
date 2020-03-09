//
//  Committment.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import CoreLocation
import MapKit

public class Task: NSObject, ObservableObject {
    var neederUser = User(name: "Nobody", surname: "accepted", email: "", photoURL: URL(string: "a")!, isHelper: 1)
    let title: String
    let descr: String?
    let date: Date
    var position: CLLocation
    let ID: Int
    var helperUser: User?
    @Published var etaText = "Calculating..."
    @Published var address = "Locating..."
    @Published var city = "Locating..."
    

    override init() {
        self.neederUser = User(name: "Tim", surname: "Cook", email: "timcook@apple.com", photoURL: URL(string: "tim")!)
        self.title = "Default title"
        self.descr = "Default description"
        self.date = Date()
        ID = Int()
        position = CLLocation(latitude: 40.675293, longitude: 14.772105)
        super.init()
    }
    
    
//    init(neederUser: User, title: String, descr: String, date: Date, position: CLLocation, ID: Int) {
//        self.neederUser = neederUser
//        self.title = title
//        self.descr = descr
//        self.date = date
//        self.ID = ID
//        self.position = position
//        super.init()
//    }
    
    init(neederUser: User, title: String, descr: String, date: Date, latitude: Double, longitude: Double, ID: Int) {
        self.neederUser = neederUser
        self.title = title
        self.descr = descr
        self.date = date
        self.ID = ID
        self.position = CLLocation(latitude: latitude, longitude: longitude)
        super.init()
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
        (UIApplication.shared.delegate as! AppDelegate).mapController.coordinatesToAddress(self.position) { result, error in
            guard error == nil, let result = result else {return}
            self.address = result
            self.city = "\(result.split(separator: ",")[2])" 
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
