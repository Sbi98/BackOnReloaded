//
//  PreServerless.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 28/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//
/*

 
 //MARK: GetUserByID
 //Get a user from its id
 static func getUserByID(id: String, completion: @escaping (User?, ErrorString?)-> Void) {
     do {
         let parameters: [String: String] = ["_id": id]
         let request = initJSONRequest(urlString: ServerRoutes.getUserByID(), body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted))
         URLSession.shared.dataTask(with: request) { data, response, error in
             guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
             guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
             let name = jsonResponse["name"].stringValue
             let email = jsonResponse["email"].stringValue
             let surname = jsonResponse["surname"].stringValue
             let photoURL = URL(string: jsonResponse["photo"].stringValue)!
             completion(User(name: name, surname: surname, email: email, photoURL: photoURL, _id: id), nil)
         }.resume()
     } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
 }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
 
 
 let serverDateFormatter: DateFormatter = {
     let formatter = DateFormatter()
     formatter.locale = Locale(identifier: "en_US_POSIX")
     formatter.dateFormat = "yyyy-MM-dd HH:mm"
     return formatter
 }()

 static func getMyBondsTasks(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
     do {
         let parameters: [String: String] = ["helperID": CoreDataController.loggedUser!._id]
         let request = initJSONRequest(urlString: ServerRoutes.getMyBonds(), body: try JSONSerialization.data(withJSONObject: parameters))
         URLSession.shared.dataTask(with: request) { data, response, error in
             guard error == nil else {return completion(nil, nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
             guard let data = data, let jsonTasksAndUsers = try? JSON(data: data) else {return completion(nil, nil, "Error with returned data in " + #function)}
             var taskArray: [Task] = []
             var userArray: [User] = []
             let myTasks = jsonTasksAndUsers["tasks"]
             for (_,currentTask):(String, JSON) in myTasks {
                 let neederID = currentTask["neederID"].stringValue
                 let title = currentTask["title"].stringValue
                 let descr = currentTask["description"].string
                 let date = serverDateFormatter(date: currentTask["date"].stringValue)
                 let latitude =  currentTask["latitude"].doubleValue
                 let longitude = currentTask["longitude"].doubleValue
                 let _id = currentTask["_id"].stringValue
                 let helperID = currentTask["helperID"].stringValue
                 if helperID == CoreDataController.loggedUser!._id {
                     taskArray.append(Task(neederID: neederID, helperID: helperID, title: title, descr: descr == "" ? nil : descr, date: date, latitude: latitude, longitude: longitude, _id: _id))
                 }
             }
             let users = jsonTasksAndUsers["users"]
             for (_,currentUser):(String, JSON) in users {
                 let name = currentUser["name"].stringValue
                 let surname = currentUser["surname"].stringValue
                 let email = currentUser["email"].stringValue
                 let photoURL = URL(string: currentUser["photo"].stringValue)!
                 let _id = currentUser["_id"].stringValue
                 userArray.append(User(name: name, surname: surname == "" ? nil : surname, email: email, photoURL: photoURL, _id: _id))
             }
             completion(taskArray, userArray, nil)
         }.resume()
     } catch let error {completion(nil, nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
 }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
 
 
 
 //MARK: GetMyRequests
 //Get a user's task' ids
 static func getMyBondsRequests(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
     do {
         let parameters: [String: String] = ["neederID": CoreDataController.loggedUser!._id]
         let request = initJSONRequest(urlString: ServerRoutes.getMyBonds(), body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted))
         URLSession.shared.dataTask(with: request) { data, response, error in
             guard error == nil else {return completion(nil, nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
             guard let data = data, let jsonRequestsAndUsers = try? JSON(data: data) else {return completion(nil, nil, "Error with returned data in " + #function)}
             var requestArray: [Task] = []
             var userArray: [User] = []
             let myRequests = jsonRequestsAndUsers["tasks"]
             for (_,currentRequest):(String, JSON) in myRequests {
                 let neederID = currentRequest["neederID"].stringValue
                 let title = currentRequest["title"].stringValue
                 let descr = currentRequest["description"].string
                 let date = serverDateFormatter(date: currentRequest["date"].stringValue)
                 let latitude =  currentRequest["latitude"].doubleValue
                 let longitude = currentRequest["longitude"].doubleValue
                 let _id = currentRequest["_id"].stringValue
                 let helperID = currentRequest["helperID"].string
                 if neederID == CoreDataController.loggedUser!._id {
                     requestArray.append(Task(neederID: neederID, helperID: helperID == "" ? nil : helperID, title: title, descr: descr == "" ? nil : descr, date: date, latitude: latitude, longitude: longitude, _id: _id))
                 }
             }
             let users = jsonRequestsAndUsers["users"]
             for (_,currentUser):(String, JSON) in users {
                 let name = currentUser["name"].stringValue
                 let surname = currentUser["surname"].stringValue
                 let email = currentUser["email"].stringValue
                 let photoURL = URL(string: currentUser["photo"].stringValue)!
                 let _id = currentUser["_id"].stringValue
                 userArray.append(User(name: name, surname: surname == "" ? nil : surname, email: email, photoURL: photoURL, _id: _id))
             }
             completion(requestArray, userArray, nil)
         }.resume()
     } catch let error {completion(nil, nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
 }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
 
 

 static func discoverOLD(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
     do {
         let parameters: [String: String] = ["_id": CoreDataController.loggedUser!._id]
         let request = initJSONRequest(urlString: ServerRoutes.discover(), body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted))
         URLSession.shared.dataTask(with: request) { data, response, error in
             guard error == nil else {return completion(nil, nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
             guard let data = data, let jsonDiscoverables = try? JSON(data: data) else {return completion(nil, nil, "Error with returned data in " + #function)}
             var taskToDiscover: [Task] = []
             var userToDiscover: [User] = []
             let discoverableTasks = jsonDiscoverables["tasks"]
             for (_,currentTask):(String, JSON) in discoverableTasks {
                 let neederID = currentTask["neederID"].stringValue
                 let title = currentTask["title"].stringValue
                 let descr = currentTask["description"].string
                 let date = serverDateFormatter(date: currentTask["date"].stringValue)
                 let latitude =  currentTask["latitude"].doubleValue
                 let longitude = currentTask["longitude"].doubleValue
                 let _id = currentTask["_id"].stringValue
                 taskToDiscover.append(Task(neederID: neederID, helperID: nil, title: title, descr: descr == "" ? nil : descr, date: date, latitude: latitude, longitude: longitude, _id: _id))
             }
             let discoverableUsers = jsonDiscoverables["users"]
             for (_,currentUser):(String, JSON) in discoverableUsers {
                 let name = currentUser["name"].stringValue
                 let surname = currentUser["surname"].stringValue
                 let email = currentUser["email"].stringValue
                 let photoURL = URL(string: currentUser["photo"].stringValue)!
                 let _id = currentUser["_id"].stringValue
                 userToDiscover.append(User(name: name, surname: surname == "" ? nil : surname, email: email, photoURL: photoURL, _id: _id))
             }
             completion(taskToDiscover, userToDiscover, nil)
         }.resume()
     } catch let error {completion(nil, nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
 }
 
 
 
 /*MARK: GetBondByID
  Get a user's request or task from its id
  static func getBondByID(id: String, completion: @escaping ((Task?, User?), ErrorString?)-> Void){
  print("getBondByID")
  
  let parameters: [String: String] = ["_id": id]
  print(parameters)
  //now create the URLRequest object using the url object
  var request = URLRequest(url: URL(string: ServerRoutes.getBondByID())!)
  request.httpMethod = "POST" //set http method as POST
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  request.addValue("application/json", forHTTPHeaderField: "Accept")
  do {
  request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
  } catch let error {
  completion(nil, "Error in" + #function + "client error: " + error.localizedDescription)
  }
  
  URLSession.shared.dataTask(with: request) { data, response, error in
  guard error == nil else {return completion(nil, "Error in " + #function + ": " + error!.localizedDescription)}
  //            print(data ?? "O-OH!")
  //            print("Faccio l'if!")
  if let data = data {
  //                print("Hey,sono qui!")
  if let jsonResponse = try? JSON(data: data){
  //                    print("Ci entro!")
  let neederID = jsonResponse["neederID"].stringValue
  print(neederID)
  let title = jsonResponse["title"].stringValue
  let descr = jsonResponse["description"].stringValue
  //                    let date = serverDateFormatter.date(from: jsonResponse["date"].stringValue)!
  let date = Date()
  let latitude =  jsonResponse["latitude"].doubleValue
  let longitude = jsonResponse["longitude"].doubleValue
  let id = jsonResponse["_id"].stringValue
  let helperID = jsonResponse["helperID"].stringValue
  completion(Task(neederID: neederID, helperID: helperID == "" ? nil : helperID, title: title, descr: descr == "" ? nil : descr, date: date, latitude: latitude, longitude: longitude, _id: id), nil)
  }
  }
  }.resume()
  }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
  */

 */
