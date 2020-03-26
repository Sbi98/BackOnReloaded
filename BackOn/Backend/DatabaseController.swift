//
//  DatabaseController.swift
//  BackOn
//
//  Created by Giancarlo Sorrentino on 18/02/2020.
//  Copyright © 2020 Giancarlo Sorrentino. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON


struct ServerRoutes {
    private static let mainRoute = "https://ac2866e2.ngrok.io/api"
    private static let signupRoute = "/auth/signin"
    private static let getUserByIDRoute = "/auth/getUserByid"
    private static let getBondByIDRoute = "/tasks/bond"
    private static let getMyBondsRoute = "/tasks/getMyTasks"
    private static let removeTaskRoute = "/tasks/cancelTask"
    private static let removeRequestRoute = "/tasks/deleteRequest"
    private static let discoverRoute = "/tasks/discover"
    private static let addRequestRoute = "/tasks/addRequest"
    private static let addTaskRoute = "/tasks/addTask"
    
    static func signUp() -> String{
        return mainRoute + signupRoute
    }
    static func getUserByID () -> String{
        return mainRoute + getUserByIDRoute
    }
    static func getBondByID() -> String{
        return mainRoute + getBondByIDRoute
    }
    static func getMyBonds () -> String{
        return mainRoute + getMyBondsRoute
    }
    static func removeTasks() -> String{
        return mainRoute + removeTaskRoute
    }
    static func removeRequest () -> String{
        return mainRoute + removeRequestRoute
    }
    static func discover() -> String{
        return mainRoute + discoverRoute
    }
    static func addRequest () -> String{
        return mainRoute + addRequestRoute
    }
    static func addTask() -> String{
        return mainRoute + addTaskRoute
    }
}

//let serverDateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.locale = Locale(identifier: "en_US_POSIX")
//    formatter.dateFormat = "yyyy-MM-dd HH:mm"
//    return formatter
//}()

class DatabaseController {
    private static func initJSONRequest(urlString: String, body: Data, httpMethod: String = "POST") -> URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body
        return request
    }
    
    static func loadFromServer() {
        getMyRequests(){ requests, users, error in
            guard error == nil, let requests = requests, let users = users else {return} //FAI L'ALERT!
            DispatchQueue.main.async {
                let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                for request in requests {
                    shared.myRequests[request._id] = request
                }
                for user in users {
                    shared.users[user._id] = user
                }
            }
        }
        getMyTasks(){ tasks, users, error in
            guard error == nil, let tasks = tasks, let users = users else {return} //FAI L'ALERT!
            DispatchQueue.main.async {
                let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                for task in tasks {
                    shared.myTasks[task._id] = task
                }
                for user in users {
                    shared.users[user._id] = user
                }
            }
        }
        discover(){ discTasks, discUsers, error in
            guard error == nil, let discTasks = discTasks, let discUsers = discUsers else {return} //FAI L'ALERT!
            DispatchQueue.main.async {
                let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                for task in discTasks {
                    shared.myDiscoverables[task._id] = task
                }
                for user in discUsers {
                    shared.users[user._id] = user
                }
            }
        }
    }
    
    
    //    MARK: SignUp
    //    Updating the current user and adding it to the databbase if absent
    static func signUp(name: String, surname: String?, email: String, photoURL: URL, completion: @escaping (User?, ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["name": name, "surname": surname ?? "", "email" : email, "photo": "\(photoURL)"]
            let request = initJSONRequest(urlString: ServerRoutes.signUp(), body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
                let _id = jsonResponse["_id"].stringValue
                completion(User(name: name, surname: surname, email: email, photoURL: photoURL, _id: _id), nil)
            }.resume()
        } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
    
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
    
    
    //MARK: GetMyTasks
    //Get a user's task' ids and, if absent, adds it into the database
    static func getMyTasks(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["helperID": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.getMyBonds(), body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted))
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
    static func getMyRequests(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
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
    
    //MARK: AddRequest
    //Adding a request from current user
    static func addRequest(title: String, description: String?, date: Date, coordinates: CLLocationCoordinate2D, completion: @escaping (Task?, ErrorString?)-> Void) {
        do {
            let parameters: [String: Any] = ["title": title, "description": description ?? "" , "neederID" : CoreDataController.loggedUser!._id, "date": serverDateFormatter(date: date), "latitude": coordinates.latitude , "longitude": coordinates.longitude]
            let request = initJSONRequest(urlString: ServerRoutes.addRequest(), body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
                let _id = jsonResponse["_id"].stringValue
                completion(Task(neederID: CoreDataController.loggedUser!._id, helperID: nil, title: title, descr: description, date: date, latitude: coordinates.latitude, longitude: coordinates.longitude, _id: _id), nil)
            }.resume()
        } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
        //        ATTENZIONE!!! CAMBIA LA DATA SOPRA!
    } //Error handling missing, but should work
    
    //MARK: AddTask
    //Adding a task for current user
    static func addTask(toAccept: Task, completion: @escaping (ErrorString?)-> Void){
        do {
            let parameters: [String: String] = ["_id": toAccept._id, "helperID": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.addTask(), body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted), httpMethod: "PUT")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion("Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion("Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion("Invalid response code in \(#function): \(responseCode)")}
                completion(nil)
            }.resume()
        } catch let error {completion("Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    } //Error handling missing, but should work
    
    //MARK: RemoveRequest
    //Removes a request by its id
    static func removeRequest(requestid: String, completion: @escaping (ErrorString?)-> Void) {
        removeBond(idToRemove: requestid, isRequest: true, completion: completion)
    }
    
    //MARK: RemoveTask
    //Removes a task by its id
    static func removeTask(taskid: String, completion: @escaping (ErrorString?)-> Void) {
        removeBond(idToRemove: taskid, isRequest: false, completion: completion)
    }
    
    private static func removeBond(idToRemove: String, isRequest: Bool, completion: @escaping (ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["_id": idToRemove]
            let request = initJSONRequest(urlString: isRequest ? ServerRoutes.removeRequest() : ServerRoutes.removeTasks(), body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted), httpMethod: isRequest ? "DELETE" : "PUT")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion("Error in " + #function + " opering with a \(isRequest ? "request" : "task"). The error is:\n" + error!.localizedDescription)}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion("Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion("Invalid response code in \(#function): \(responseCode)")}
                completion(nil)
            }.resume()
        } catch let error {completion("Error in " + #function + " opering with a \(isRequest ? "request" : "task"). The error is:\n" + error.localizedDescription)}
    }
    
    static func updateCathegories(lastUpdate: Date){
        //Chiede l'ultima data di aggiornamento delle categorie di request al db e, se diversa da quella che ha internamente, richiede al db di inviarle e le aggiorna
        //Apro la connessione, ottengo la data, se diversa faccio la richiesta altrimenti chiudo
    }
    
    static func discover(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
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
    
    
    static func serverDateFormatter(date:String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let parsedDate = formatter.date(from: date) {
            return parsedDate
        }
        return Date()
    }
    
    static func serverDateFormatter(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return formatter.string(from: date)
    }
    
    
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
