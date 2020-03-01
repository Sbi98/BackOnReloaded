//
//  Committment.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Commitment: ObservableObject{
    var userInfo = UserInfo(name: "Nobody", surname: "accepted", email: "", photoURL: URL(string: "a")!, isHelper: 1)
    let title: String
    let descr: String
    let date: Date
    let ID: Int
    @Published var etaText = "Calculating..."
    
    var position: CLLocation
    var textAddress: String?

    
    init() {
        self.userInfo = UserInfo(photo: URL(string: "tim")!, name: "Tim", surname: "Cook")
        self.title = "Default title"
        self.descr = "Default description"
        self.date = Date()
        ID = Int()
        position = CLLocation(latitude: 40.675293, longitude: 14.772105)
    }
    
    init(userInfo: UserInfo, title: String, descr: String, date: Date, position: CLLocation) {
        self.userInfo = userInfo
        self.title = title
        self.descr = descr
        self.date = date
        ID = Int()
        self.position = position
    }
    
    init(userInfo: UserInfo, title: String, descr: String, date: Date, ID: Int) {
        self.userInfo = userInfo
        self.title = title
        self.descr = descr
        self.date = date
        self.ID = ID
        position = CLLocation(latitude: 40.675293, longitude: 14.772105)
    }
    
    init(userInfo: UserInfo, title: String, descr: String, date: Date, position: CLLocation, ID: Int) {
        self.userInfo = userInfo
        self.title = title
        self.descr = descr
        self.date = date
        self.ID = ID
        self.position = position
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
            if eta > 3600{
                self.etaText = "\(Int(eta/3600)) \(hour) \(Int((Int(eta)%3600)/60)) min by walk"
            } else {
                self.etaText = "\(Int(eta/60)) min by walk"
            }
        }
    }
}

//  Questo metodo da un array di commitment restituisce il più imminente assumendo che:
func getNextCommitment(dataDictionary: [Int:Commitment]) -> Commitment? {
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

func getNextNotificableCommitment(dataDictionary: [Int:Commitment]) -> Commitment? {
    if(dataDictionary.count == 0){
        return nil
    }
    var data = Array(dataDictionary.values)
    var toReturn: Commitment?
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
 
 func getNextFive(dataDictionary: [Int: Commitment]) -> [Commitment]{
      let data = Array(dataDictionary.values)
      var toReturn: [Commitment] = [data[0]]
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
