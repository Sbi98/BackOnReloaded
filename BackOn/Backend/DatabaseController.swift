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

class DatabaseController {
    static func loadFromServer() {
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
        getMyRequests(){ requests, users, error in
            guard error == nil, let requests = requests, let users = users else {print("ops");return} //FAI L'ALERT!
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
    }
    
    static func signUp(name: String, surname: String?, email: String, photoURL: URL, completion: @escaping (User?, ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["name": name, "surname": surname ?? "", "email" : email, "photo": "\(photoURL)"]
            let request = initJSONRequest(urlString: ServerRoutes.signUp, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
                let _id = jsonResponse["_id"].stringValue
                completion(User(name: name, surname: surname, email: email, photoURL: photoURL, _id: _id), nil)
            }.resume()
        } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE


    static func getMyTasks(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["helperID": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.getMyTasks, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, var jsonArray = try? JSON(data: data).arrayValue else {return completion(nil, nil, "Error with returned data in " + #function)}
                var taskArray: [Task] = []
                var userDict: [String:User] = [:]
                parseJSONArray(jsonArray: &jsonArray, taskArray: &taskArray, userDict: &userDict)
                completion(taskArray, Array(userDict.values), nil)
            }.resume()
        } catch let error {completion(nil, nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }
    
    static func getMyRequests(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["neederID": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.getMyRequests, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, var jsonArray = try? JSON(data: data).arrayValue else {return completion(nil, nil, "Error with returned data in " + #function)}
                var taskArray: [Task] = []
                var userDict: [String:User] = [:]
                parseJSONArray(jsonArray: &jsonArray, taskArray: &taskArray, userDict: &userDict)
                completion(taskArray, Array(userDict.values), nil)
            }.resume()
        } catch let error {completion(nil, nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }
    
    static func discover(completion: @escaping ([Task]?, [User]?, ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["_id": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.discover, body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, var jsonDiscoverables = try? JSON(data: data).arrayValue else {return completion(nil, nil, "Error with returned data in " + #function)}
                var taskToDiscover: [Task] = []
                var userToDiscover: [String:User] = [:]
                parseJSONArray(jsonArray: &jsonDiscoverables, taskArray: &taskToDiscover, userDict: &userToDiscover)
                completion(taskToDiscover, Array(userToDiscover.values), nil)
            }.resume()
        } catch let error {completion(nil, nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }
    
    static func addRequest(title: String, description: String?, date: Date, coordinates: CLLocationCoordinate2D, completion: @escaping (Task?, ErrorString?)-> Void) {
        do {
            let parameters: [String: Any] = ["title": title, "description": description ?? "" , "neederID" : CoreDataController.loggedUser!._id, "date": serverDateFormatter(date: date), "latitude": coordinates.latitude , "longitude": coordinates.longitude]
            let request = initJSONRequest(urlString: ServerRoutes.addRequest, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
                let _id = jsonResponse["_id"].stringValue
                completion(Task(neederID: CoreDataController.loggedUser!._id, helperID: nil, title: title, descr: description, date: date, latitude: coordinates.latitude, longitude: coordinates.longitude, _id: _id), nil)
            }.resume()
        } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    } //Error handling missing, but should work

    static func addTask(toAccept: Task, completion: @escaping (ErrorString?)-> Void){
        do {
            let parameters: [String: String] = ["_id": toAccept._id, "helperID": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.addTask, body: try JSONSerialization.data(withJSONObject: parameters), httpMethod: "PUT")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion("Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion("Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion("Response code != 200 in \(#function): \(responseCode)")}
                completion(nil)
            }.resume()
        } catch let error {completion("Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    } //Error handling missing, but should work
    
    static func removeRequest(requestid: String, completion: @escaping (ErrorString?)-> Void) {
        removeBond(idToRemove: requestid, isRequest: true, completion: completion)
    }
    
    static func removeTask(taskid: String, completion: @escaping (ErrorString?)-> Void) {
        removeBond(idToRemove: taskid, isRequest: false, completion: completion)
    }
    
    static func stashTask(toStash: Task, report: String, completion: @escaping (ErrorString?)-> Void){
        do {
            let parameters: [String: Any] = ["_id" : toStash._id, "title" : toStash.title, "description" : toStash.descr ?? "" , "neederID" : toStash.neederID , "date" : serverDateFormatter(date: toStash.date), "latitude" : toStash.position.coordinate.latitude, "longitude" : toStash.position.coordinate.longitude , "helperID" : toStash.helperID ?? "Error! NO HELPER!", "report" : report]
            let request = initJSONRequest(urlString: ServerRoutes.stashTask, body: try JSONSerialization.data(withJSONObject: parameters), httpMethod: "PUT")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion("Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion("Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion("Response code != 200 in \(#function): \(responseCode)")}
                completion(nil)
            }.resume()
        } catch let error {completion("Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    } //Error handling missing, but should work
    
    private static func removeBond(idToRemove: String, isRequest: Bool, completion: @escaping (ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["_id": idToRemove]
            let request = initJSONRequest(urlString: isRequest ? ServerRoutes.removeRequest : ServerRoutes.removeTask, body: try JSONSerialization.data(withJSONObject: parameters), httpMethod: isRequest ? "DELETE" : "PUT")
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
    
    private static func parseJSONArray(jsonArray: inout [JSON], taskArray: inout [Task], userDict: inout [String:User]) {
        for current: JSON in jsonArray {
            let neederID = current["neederID"].stringValue
            let title = current["title"].stringValue
            let descr = current["description"].string
            let date = serverDateFormatter(date: current["date"].stringValue)
            let latitude =  current["latitude"].doubleValue
            let longitude = current["longitude"].doubleValue
            let _id = current["_id"].stringValue
            taskArray.append(Task(neederID: neederID, helperID: nil, title: title, descr: descr == "" ? nil : descr, date: date, latitude: latitude, longitude: longitude, _id: _id))
            let user = current["user"].arrayValue.first
            if user != nil {
                let user = user!
                let userID = user["_id"].stringValue //Superfluo, che facciamo?
                let userName = user["name"].stringValue
                let userSurname = user["surname"].stringValue
                let userEmail = user["email"].stringValue
                let userPhoto = URL(string: user["photo"].stringValue)!
                if userDict[userID] == nil {
                    userDict[userID] = User(name: userName, surname: userSurname == "" ? nil : userSurname, email: userEmail, photoURL: userPhoto, _id: userID)
                }
            }
        }
    }
    
    private static func initJSONRequest(urlString: String, body: Data, httpMethod: String = "POST") -> URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body
        return request
    }
    
    private static func serverDateFormatter(date:String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let parsedDate = formatter.date(from: date) {
            return parsedDate
        }
        return Date()
    }
    
    private static func serverDateFormatter(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.string(from: date)
    }
    
    
}

