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
        refreshToken()
        discover(){ discTasks, discUsers, error in
            guard error == nil, let discTasks = discTasks, let discUsers = discUsers else {print(error!);return} //FAI L'ALERT!
            var shouldRequestETA = false
            let now = Date()
            if MapController.lastLocation != nil { // serve solo se per qualche motivo la posizione precisa è disponibile prima di avere i set popolati
                shouldRequestETA = MapController.lastLocation!.horizontalAccuracy < 35.0 ? true : false
            }
            for task in discTasks.values {
                if task.date > now {
                    if shouldRequestETA { task.requestETA() }
                    task.locate()
                    DispatchQueue.main.async { (UIApplication.shared.delegate as! AppDelegate).shared.myDiscoverables[task._id] = task }
                }
            }
            for user in discUsers.values {
                DispatchQueue.main.async {
                    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                    if shared.discUsers[user._id] == nil {
                        shared.discUsers[user._id] = user
                    }
                }
            }
            print("*** DB - discover finished ***")
        }
        getMyBonds(){ tasks, requests, users, error in
            guard error == nil, let tasks = tasks, let requests = requests, let users = users else {print(error!);return} //FAI L'ALERT!
            var shouldRequestETA = false
            let now = Date()
            DispatchQueue.main.async {
                let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                for taskid in shared.myTasks.keys { //cancella (anche da CoreData) tutti i task non più presenti nella risposta del server
                    if tasks[taskid] == nil {
                        CoreDataController.deleteTask(task: shared.myTasks[taskid]!, save: false)
                        shared.myTasks[taskid] = nil
                    }
                }
                for requestid in shared.myRequests.keys { //cancella (anche da CoreData) tutte le request non più presenti nella risposta del server
                    if requests[requestid] == nil {
                        CoreDataController.deleteTask(task: shared.myRequests[requestid]!, save: false)
                        shared.myRequests[requestid] = nil
                    }
                }
                for userid in shared.users.keys { //cancella (anche da CoreData) tutti gli utenti non più presenti nella risposta del server
                    if users[userid] == nil {
                        CoreDataController.deleteUser(user: shared.users[userid]!, save: false)
                        shared.users[userid] = nil
                    }
                }
                if MapController.lastLocation != nil { // serve solo se per qualche motivo la posizione precisa è disponibile prima di avere i set popolati
                    shouldRequestETA = MapController.lastLocation!.horizontalAccuracy < 35.0 ? true : false
                }
                for task in tasks.values {
                    if task.date < now && task.neederReport == nil && shared.myExpiredTasks[task._id] == nil{ // se è un task scaduto e non esisteva lo aggiunge
                        task.locate()
                        CoreDataController.addTask(task: task, save: false)
                        shared.myExpiredTasks[task._id] = task
                    }
                    if task.date > now && shared.myTasks[task._id] == nil { // se è un task attivo e non esisteva lo aggiunge
                        if shouldRequestETA { task.requestETA() }
                        task.locate()
                        MapController.getSnapshot(location: task.position.coordinate){ snapshot, error in
                            guard error == nil, let snapshot = snapshot else {print("Error while getting snapshot in getMyBonds");return}
                            task.mapSnap = snapshot.image
                        }
                        CoreDataController.addTask(task: task, save: false)
                        shared.myTasks[task._id] = task
                    }
                }
                for request in requests.values {
                    if request.date < now { // se è una richiesta scaduta e non esisteva la aggiunge
                        if shared.myExpiredRequests[request._id] == nil && request.helperID != nil && request.helperReport == nil {
                            request.locate()
                            CoreDataController.addTask(task: request, save: false)
                            shared.myExpiredRequests[request._id] = request
                        }
                    } else {
                        let corrispondent = shared.myRequests[request._id]
                        if corrispondent == nil { // se non esisteva la aggiunge
                            request.locate()
                            CoreDataController.addTask(task: request, save: false)
                            shared.myRequests[request._id] = request
                        } else {
                            if corrispondent!.helperID != request.helperID { // se esisteva ma l'helper è diverso lo aggiorna
                                corrispondent!.helperID = request.helperID
                                CoreDataController.updateRequest(request: request, save: false)
                            }
                        }
                    }
                }
                for user in users.values {
                    let corrispondent = shared.users[user._id]
                    if corrispondent == nil {
                        shared.users[user._id] = user
                        CoreDataController.addUser(user: user, save: false)
                    } else {
                        if corrispondent!.identity != user.identity || corrispondent!.photoURL != user.photoURL {
                            CoreDataController.updateUser(user: user, save: false)
                        }
                    }
                }
                do {
                    try CoreDataController.saveContext()
                } catch {print("Error while saving context")}
                print("*** DB - getMyBonds finished ***")
            }
        }
    }
    
    static func signUp(name: String, surname: String?, email: String, photoURL: URL, completion: @escaping (User?, ErrorString?)-> Void) {
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: String] = ["name": name, "surname": surname ?? "", "email" : email, "photo": "\(photoURL)", "deviceToken": CoreDataController.deviceToken]
            let request = initJSONRequest(urlString: ServerRoutes.signUp, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
                let _id = jsonResponse["_id"].stringValue
                completion(User(name: name, surname: surname, email: email, photoURL: photoURL, _id: _id), nil)
            }.resume()
        } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
    
    
    static func getMyBonds(completion: @escaping ([String:Task]?, [String:Task]?, [String:User]?, ErrorString?)-> Void) {
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: String] = ["_id": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.getMyBonds, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil,nil,nil,"Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,nil,nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,nil,nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, let jsonTasksAndRequests = try? JSON(data: data) else {return completion(nil,nil,nil,"Error with returned data in " + #function)}
                var tasksJSONArray = jsonTasksAndRequests["tasks"].arrayValue
                var requestsJSONArray = jsonTasksAndRequests["requests"].arrayValue
                var taskDict: [String:Task] = [:]
                var requestDict: [String:Task] = [:]
                var userDict: [String:User] = [:]
                parseJSONArray(jsonArray: &tasksJSONArray, taskDict: &taskDict, userDict: &userDict)
                parseJSONArray(jsonArray: &requestsJSONArray, taskDict: &requestDict, userDict: &userDict)
                completion(taskDict, requestDict, userDict, nil)
            }.resume()
        } catch let error {completion(nil,nil,nil,"Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }
    
    static func discover(completion: @escaping ([String:Task]?, [String:User]?, ErrorString?)-> Void) {
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: String] = ["_id": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.discover, body: try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, var jsonDiscoverables = try? JSON(data: data).arrayValue else {return completion(nil, nil, "Error with returned data in " + #function)}
                var taskToDiscover: [String:Task] = [:]
                var userToDiscover: [String:User] = [:]
                parseJSONArray(jsonArray: &jsonDiscoverables, taskDict: &taskToDiscover, userDict: &userToDiscover)
                completion(taskToDiscover, userToDiscover, nil)
            }.resume()
        } catch let error {completion(nil, nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }
    
    static func addRequest(title: String, description: String?, address: String, city: String, date: Date, coordinates: CLLocationCoordinate2D, completion: @escaping (Task?, ErrorString?)-> Void) {
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: Any] = ["title": title, "description": description ?? "" , "neederID" : CoreDataController.loggedUser!._id, "date": serverDateFormatter(date: date), "latitude": coordinates.latitude , "longitude": coordinates.longitude]
            let request = initJSONRequest(urlString: ServerRoutes.addRequest, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
                let _id = jsonResponse["_id"].stringValue
                completion(Task(neederID: CoreDataController.loggedUser!._id, helperID: nil, title: title, descr: description, date: date, latitude: coordinates.latitude, longitude: coordinates.longitude, _id: _id, address: address, city: city), nil)
            }.resume()
        } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    } //Error handling missing, but should work
    
    static func addTask(toAccept: Task, completion: @escaping (ErrorString?)-> Void){
        do {
            print("*** DB - \(#function) ***")
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
        print("*** DB - \(#function) ***")
        removeBond(idToRemove: requestid, isRequest: true, completion: completion)
    }
    
    static func removeTask(taskid: String, completion: @escaping (ErrorString?)-> Void) {
        print("*** DB - \(#function) ***")
        removeBond(idToRemove: taskid, isRequest: false, completion: completion)
    }
    
    static func reportTask(task: Task, report: String, helperToReport: Bool, completion: @escaping (ErrorString?)-> Void){
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: Any] = ["_id" : task._id, (helperToReport ? "helperReport" : "neederReport") : report]
            let request = initJSONRequest(urlString: ServerRoutes.reportTask, body: try JSONSerialization.data(withJSONObject: parameters), httpMethod: "PUT")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion("Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion("Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion("Response code != 200 in \(#function): \(responseCode)")}
                completion(nil)
            }.resume()
        } catch let error {completion("Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }
    
    ////  Non deve più esistere: sostituito con report bilaterale, stash a posteriori.
    //    static func stashTask(toStash: Task, report: String, completion: @escaping (ErrorString?)-> Void){
    //        do {
    //            print("*** DB - \(#function) ***")
    //            let parameters: [String: Any] = ["_id" : toStash._id, "title" : toStash.title, "description" : toStash.descr ?? "" , "neederID" : toStash.neederID , "date" : serverDateFormatter(date: toStash.date), "latitude" : toStash.position.coordinate.latitude, "longitude" : toStash.position.coordinate.longitude , "helperID" : toStash.helperID ?? "Error! NO HELPER!", "report" : report]
    //            let request = initJSONRequest(urlString: ServerRoutes.stashTask, body: try JSONSerialization.data(withJSONObject: parameters), httpMethod: "PUT")
    //            URLSession.shared.dataTask(with: request) { data, response, error in
    //                guard error == nil else {return completion("Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
    //                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion("Error in " + #function + ". Invalid response!")}
    //                guard responseCode == 200 else {return completion("Response code != 200 in \(#function): \(responseCode)")}
    //                completion(nil)
    //            }.resume()
    //        } catch let error {completion("Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    //    } //Error handling missing, but should work
    
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
    
    static func updateCathegories(lastUpdate: Date) {
        //Chiede l'ultima data di aggiornamento delle categorie di request al db e, se diversa da quella che ha internamente, richiede al db di inviarle e le aggiorna
        //Apro la connessione, ottengo la data, se diversa faccio la richiesta altrimenti chiudo
    }
    
    static func refreshToken(){
        do{
            print("*** DB - \(#function) ***")
            let parameters: [String: String] = ["deviceToken": CoreDataController.deviceToken, "_id": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.signUp, body: try JSONSerialization.data(withJSONObject: parameters), httpMethod: "POST")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {print("Error in " + #function + ". The error is:\n" + error!.localizedDescription); return}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {print("Error in " + #function + ". The error is:\n" + error!.localizedDescription); return}
                guard responseCode == 200 else {print("Invalid response code in \(#function): \(responseCode)"); return}
            }.resume()
        } catch{
            print("Error in " + #function + ". The error is:\n" + error.localizedDescription)
        }
    }
    
    private static func parseJSONArray(jsonArray: inout [JSON], taskDict: inout [String:Task], userDict: inout [String:User]) {
        let myID = CoreDataController.loggedUser!._id
        for current: JSON in jsonArray {
            let neederID = current["neederID"].stringValue
            let title = current["title"].stringValue
            let descr = current["description"].string
            let date = serverDateFormatter(date: current["date"].stringValue)
            let latitude =  current["latitude"].doubleValue
            let longitude = current["longitude"].doubleValue
            let _id = current["_id"].stringValue
            let helperID = current["helperID"].string
            let helperReport = current["helperReport"].string
            let neederReport = current["neederReport"].string
            guard (myID != neederID && myID != helperID) || (myID == neederID && helperReport == nil) || (myID == helperID && neederReport == nil) else {continue}
            taskDict[_id] = Task(neederID: neederID, helperID: helperID, title: title, descr: descr == "" ? nil : descr, date: date, latitude: latitude, longitude: longitude, _id: _id)
            let user = current["user"].arrayValue.first
            if user != nil {
                let user = user!
                let userID = user["_id"].stringValue //Superfluo, che facciamo?
                if userDict[userID] == nil {
                    let userName = user["name"].stringValue
                    let userSurname = user["surname"].stringValue
                    let userEmail = user["email"].stringValue
                    let userPhoto = URL(string: user["photo"].stringValue)!
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
        //request.setValue("close", forHTTPHeaderField: "Connection")
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
