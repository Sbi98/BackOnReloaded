//
//  DatabaseController.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 18/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI
import SwiftyJSON

class DatabaseController {
    let serverIPandPort = "87.20.37.106:8180"
    let shared: Shared
    //    let coreDataController = (UIApplication.shared.delegate as! AppDelegate)
    
    init(shared: Shared) {
        self.shared = shared
    }
    //    MARK: USER
    
    //    Salvo l'utente nel database
    func registerUser(user: User) {
        print("registerUser")
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        let parameters: [String: String] = ["name": user.name, "surname": user.surname ?? "", "email" : user.email, "photo": "\(user.photoURL)"]
        
        //create the url with URL
        let url = URL(string: "http://\(self.serverIPandPort)/NewBackOn-0.0.1-SNAPSHOT/RegisterUser")! //change the url
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        
        //SE VOGLIO LEGGERE I DATI DAL SERVER
        URLSession.shared.dataTask(with: request) { data, response, error in
        }.resume()
    }
    
    //MARK: GetCommitByUser
    // Usata dal needer per vedere le sue richieste di aiuto
    func getCommitByUser() {
        print("*** getCommitByUser ***")
        let userEmail: String = CoreDataController.loggedUser!.email
        let parameters: [String: String] = ["email": userEmail]
        
        //create the url with URL
        let url = URL(string: "http://\(self.serverIPandPort)/NewBackOn-0.0.1-SNAPSHOT/GetCommitByUserEmail")! //change the url
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        
        //SE VOGLIO LEGGERE I DATI DAL SERVER
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else{
                        print("Error while getting user's commitments!")
                        return
                    }
                    
                    if let array = json as? NSArray {
                        for obj in array {
                            if let dict = obj as? NSDictionary {
                                
                                let id = dict.value(forKey: "id")
                                let descrizione = dict.value(forKey: "description")
                                let data = dict.value(forKey: "date")
                                let latitude = dict.value(forKey: "latitude")
                                let longitude = dict.value(forKey: "longitude")
                                let title = dict.value(forKey: "titolo")
                                let dateFormatter = DateFormatter()
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                let date = dateFormatter.date(from:"\(data!)")!
                                let isAccepted = dict.value(forKey: "isAccepted")
                                //let position: CLLocation = CLLocation(latitude: (latitude as! NSString).doubleValue, longitude: (longitude as! NSString).doubleValue)
                                var c: Task
                                
                                if (isAccepted! as! Int) == 1 {
                                    let userEmail = dict.value(forKey: "userEmail")
                                    let userPhoto = dict.value(forKey: "userPhoto")
                                    let userSurname = dict.value(forKey: "userSurname")
                                    let userName = dict.value(forKey: "userName")
                                    let userStatus = dict.value(forKey: "userStatus")
                                    let user = User(name: userName! as! String, surname: userSurname! as! String, email: userEmail! as! String, photoURL: URL(string: userPhoto! as! String)!, isHelper: userStatus! as! Int)
                                    c = Task(neederUser: user, title: title! as! String, descr: descrizione! as! String, date: date, latitude: (latitude as! NSString).doubleValue, longitude: (longitude as! NSString).doubleValue, ID: id! as! Int)
                                } else {
                                    let nobodyHelped = User(name: "Nobody", surname: "accepted", email: "", photoURL: URL(string: "a")!, isHelper: 1)
                                    c = Task(neederUser: nobodyHelped, title: title! as! String, descr: descrizione! as! String, date: date, latitude: (latitude as! NSString).doubleValue, longitude: (longitude as! NSString).doubleValue, ID: id! as! Int)
                                }
                                
                                self.shared.myRequests[id! as! Int] = c
                            }
                            
                        }
                    }
                }
                }
            }.resume()
        }
        
        //MARK: InsertCommit
        func insertCommit(title: String, description: String, date: Date, latitude: Double, longitude: Double) {
            print("INSERT COMMIT")
            let userEmail: String = CoreDataController.loggedUser!.email
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm"
            let formattedDate = format.string(from: date)
            print(formattedDate)
            
            let parameters: [String: String] = ["title":"\(title)", "description": "\(description)", "email": userEmail, "date":"\(formattedDate)","latitude":"\(latitude)", "longitude":"\(longitude)"]
            
            //create the url with URL
            let url = URL(string: "http://\(self.serverIPandPort)/NewBackOn-0.0.1-SNAPSHOT/InsertCommit")! //change the url
            
            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //create dataTask using the session object to send data to the server
            
            //SE VOGLIO LEGGERE I DATI DAL SERVER
            URLSession.shared.dataTask(with: request) { data, response, error in
            }.resume()
        }
        
        //    MARK: COMMITMENT
        //    To Do
        func insertCommitment(userEmail: String, commitId: Int) {
            
            let parameters: [String: String] = ["userEmail": userEmail, "commitId": "\(commitId)"]
            
            //create the url with URL
            let url = URL(string: "http://\(serverIPandPort)/NewBackOn-0.0.1-SNAPSHOT/InsertCommitment")! //change the url
            
            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //create dataTask using the session object to send data to the server
            
            //SE VOGLIO LEGGERE I DATI DAL SERVER
            URLSession.shared.dataTask(with: request) { data, response, error in
            }.resume()
        }
        
        //MARK: loadMyCommitments
        func loadMyCommitments() {
            print("*** loadMyCommits ***")
            let userEmail: String = CoreDataController.loggedUser!.email
            let parameters: [String: String] = ["email": userEmail]
            
            //create the url with URL
            let url = URL(string: "http://\(serverIPandPort)/NewBackOn-0.0.1-SNAPSHOT/GetMyCommitments")! //change the url
            
            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //create dataTask using the session object to send data to the server
            
            //SE VOGLIO LEGGERE I DATI DAL SERVER
            self.shared.myTasks = [:]
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    let jsonArray = try? JSON(data: data)
                    
                   
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    //            da provare anche
                    for (_,dict):(String, JSON) in jsonArray! {
                        let idCommitment = dict["idCommitment"].intValue
                        let idCommit = dict["idCommit"].intValue
                        let latitudeCommit = dict["commitLatitude"].doubleValue
                        let longitudeCommit = dict["commitLongitude"].doubleValue
                        let descrizioneCommit = dict["commitDescription"].stringValue
                        let dataCommit = dateFormatter.date(from: dict["commitDate"].stringValue)
                        let titleCommit = dict["commitTitle"].stringValue
                        
                        let userEmail = dict["userEmail"].stringValue
                        let userName = dict["userName"].stringValue
                        let userSurname = dict["userSurname"].stringValue
                        let userPhoto = dict["userPhoto"].stringValue
                        let userStatus = dict["userStatus"].intValue
                        
                        let user = User(name: userName, surname: userSurname, email: userEmail, photoURL: URL(string: userPhoto)!, isHelper: userStatus)
                        
                        let c = Task(neederUser: user, title: titleCommit, descr: descrizioneCommit, date: dataCommit!, latitude: latitudeCommit, longitude: longitudeCommit, ID: idCommit)
                        
                        self.shared.myTasks[idCommitment] = c
                    }
                }
                
                
            }.resume()
        }
        
        //MARK: loadCommitByOther
        func loadCommitByOther() {
            print("*** loadCommitByOther ***")
            guard let url = URL(string: "http://\(serverIPandPort)/NewBackOn-0.0.1-SNAPSHOT/GetAllOtherCommit") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else{
                            print("Error parsing JSON when loading discoverable requests")
                            return
                        }
                        
                        let loggedUserEmail = CoreDataController.loggedUser!.email
                        
                        if let array = json as? NSArray {
                            for obj in array {
                                if let dict = obj as? NSDictionary {
                                    
                                    let userEmail = dict.value(forKey: "userEmail")
                                    
                                    if !(loggedUserEmail == userEmail! as! String) {
                                        let id = dict.value(forKey: "id")
                                        let descrizione = dict.value(forKey: "description")
                                        let data = dict.value(forKey: "date")
                                        let latitude = dict.value(forKey: "latitude")
                                        let longitude = dict.value(forKey: "longitude")
                                        let userPhoto = dict.value(forKey: "userPhoto")
                                        let userSurname = dict.value(forKey: "userSurname")
                                        let userName = dict.value(forKey: "userName")
                                        let title = dict.value(forKey: "titolo")
                                        let userStatus = dict.value(forKey: "userStatus")
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                        let date = dateFormatter.date(from:"\(data!)")!
                                        
                                        //                                    let position: CLLocation = CLLocation(latitude: (latitude as! NSString).doubleValue, longitude: (longitude as! NSString).doubleValue)
                                        
                                        let user = User(name: userName! as! String, surname: userSurname! as! String, email: userEmail! as! String, photoURL: URL(string: userPhoto! as! String)!, isHelper: userStatus! as! Int)
                                        
                                        let c = Task(neederUser: user, title: title! as! String, descr: descrizione! as! String, date: date, latitude: (latitude as! NSString).doubleValue, longitude: (longitude as! NSString).doubleValue, ID: id! as! Int)
                                        
                                        self.shared.myDiscoverables[id! as! Int] = c
                                    }
                                }
                            }
                        }
                    }
                }
            }.resume()
        }
        
    }

