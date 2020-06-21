//
//  DatabaseController.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 18/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class DatabaseController {
    static func loadFromServer() {
        refreshSignIn(){ name, surname, photoURL, caregiver, housewife, runner, smartAssistant, error in
            guard error == nil else{print(error!); return}
            updateLoggedUserInfo(name: name, surname: surname, photoURL: photoURL)
            CoreDataController.updateLoggedUser(user: CoreDataController.loggedUser!)
            for requestType in Array(Souls.weights.keys){
                let weights = Souls.weights[requestType]!
                Souls.setValue(category: requestType, newValue: caregiver! * weights.0 + housewife! * weights.1 + runner! * weights.2 + smartAssistant! * weights.3)
            }
        }
        discover(){ discTasks, discUsers, error in
            guard error == nil, let discTasks = discTasks, let discUsers = discUsers else {print(error!);return} //FAI L'ALERT!
            var shouldRequestETA = false
            let now = Date()
            if MapController.lastLocation != nil { // serve solo se per qualche motivo la posizione precisa è disponibile prima di avere i set popolati
                shouldRequestETA = MapController.lastLocation!.horizontalAccuracy < MapController.horizontalAccuracy ? true : false
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
            DispatchQueue.main.async { (UIApplication.shared.delegate as! AppDelegate).shared.canLoadAroundYouMap = true }
            print("*** DB - discover finished ***")
        }
        getMyBonds(){ tasks, requests, users, error in
            guard error == nil, let tasks = tasks, let requests = requests, let users = users else {print(error!); return} //FAI L'ALERT!
            var shouldRequestETA = false
            let now = Date()
            DispatchQueue.main.async {
                let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                for taskid in shared.myTasks.keys { //cancella (anche da CoreData) tutti i task non più presenti nella risposta del server
                    if tasks[taskid] == nil {
                        CoreDataController.deleteBond(shared.myTasks[taskid]!, save: false)
                        shared.myTasks[taskid] = nil
                    }
                }
                for requestid in shared.myRequests.keys { //cancella (anche da CoreData) tutte le request non più presenti nella risposta del server
                    if requests[requestid] == nil {
                        CoreDataController.deleteBond(shared.myRequests[requestid]!, save: false)
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
                    shouldRequestETA = MapController.lastLocation!.horizontalAccuracy < MapController.horizontalAccuracy ? true : false
                }
                for task in tasks.values {
                    if task.date < now && task.neederReport == nil && shared.myExpiredTasks[task._id] == nil { // se è un task scaduto e non esisteva lo aggiunge
                        task.locate()
                        CoreDataController.addBond(task, save: false)
                        shared.myExpiredTasks[task._id] = task
                    }
                    if task.date > now && shared.myTasks[task._id] == nil { // se è un task attivo e non esisteva lo aggiunge
                        if shouldRequestETA { task.requestETA() }
                        task.locate()
                        MapController.getSnapshot(location: task.position.coordinate, style: .dark){ snapshot, error in
                            if error == nil, let snapshot = snapshot { DispatchQueue.main.async{task.darkMapSnap = snapshot.image} }
                        }
                        MapController.getSnapshot(location: task.position.coordinate, style: .light){ snapshot, error in
                            if error == nil, let snapshot = snapshot { DispatchQueue.main.async{task.lightMapSnap = snapshot.image} }
                        }
                        // uso una dispatchqueue per dare il tempo di fare il download dello snapshot
                        DispatchQueue(label: "addTask", qos: .utility).asyncAfter(deadline: .now() + 3) {
                            CoreDataController.addBond(task, save: false)
                        }
                        shared.myTasks[task._id] = task
                    }
                }
                for request in requests.values {
                    if request.date < now { // se è una richiesta scaduta e non esisteva la aggiunge
                        if shared.myExpiredRequests[request._id] == nil && request.helperReport == nil {
                            request.locate()
                            CoreDataController.addBond(request, save: false)
                            shared.myExpiredRequests[request._id] = request
                        }
                    } else {
                        let corrispondent = shared.myRequests[request._id]
                        if corrispondent == nil { // se non esisteva la aggiunge
                            request.locate()
                            CoreDataController.addBond(request, save: false)
                            shared.myRequests[request._id] = request
                        } else {
                            if corrispondent!.helperID != request.helperID { // se esisteva ma l'helper è diverso lo aggiorna
                                corrispondent!.helperID = request.helperID
                                CoreDataController.updateRequest(request, save: false)
                            }
                        }
                    }
                }
                for user in users.values {
                    let corrispondent = shared.users[user._id]
                    if corrispondent == nil {
                        shared.users[user._id] = user
                        // uso una dispatchqueue per dare il tempo di fare il download dell'immagine dell'utente
                        DispatchQueue(label: "addUser", qos: .utility).asyncAfter(deadline: .now() + 3) {
                            CoreDataController.addUser(user: user, save: false)
                        }
                    } else {
                        if corrispondent!.identity != user.identity {
                            corrispondent!.name = user.name
                            corrispondent!.surname = user.surname
                            if corrispondent!.photoURL != user.photoURL {
                                corrispondent!.photoURL = user.photoURL
                                corrispondent!.photo = user.photo
                            }
                            CoreDataController.updateUser(user: user, save: false)
                        }
                    }
                }
                DispatchQueue(label: "saveContext", qos: .utility).asyncAfter(deadline: .now() + 5) {
                    do {
                        try CoreDataController.saveContext()
                    } catch {print("Error while saving context!")}
                }
                print("*** DB - getMyBonds finished ***")
            }
        }
    }
    
    static func updateLoggedUserInfo(name: String?, surname:String?, photoURL: String?){
        let loggedUser = CoreDataController.loggedUser!
        loggedUser.name = name!
        if(surname != nil){
            loggedUser.surname = surname!
        }
        if(photoURL != nil){
            let url = URL(string: photoURL!)
            DispatchQueue(label: "loadProfilePic", qos: .utility).async {
                do {
                    guard photoURL != nil, let uiimage = try UIImage(data: Data(contentsOf: url!)) else { return }
                    DispatchQueue.main.async { loggedUser.photo = uiimage }
                } catch {}
            }
        }
    }
    
    static func signUp(name: String, surname: String?, email: String, photoURL: URL, completion: @escaping (User?, ErrorString?)-> Void) {
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: Any?] = ["name": name, "surname": surname, "email" : email, "photo": "\(photoURL)", "deviceToken": CoreDataController.deviceToken]
            let request = initJSONRequest(urlString: ServerRoutes.signUp, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
                let _id = jsonResponse["_id"].stringValue
                completion(User(_id: _id, name: name, surname: surname, email: email, photoURL: photoURL), nil)
            }.resume()
        } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
    
    static func logout(completion: @escaping (ErrorString?)-> Void){
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: Any?] = ["_id": CoreDataController.loggedUser!._id, "logoutToken" : CoreDataController.deviceToken]
            let request = initJSONRequest(urlString: ServerRoutes.updateProfile, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion("Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion("Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion("Response code != 200 in \(#function): \(responseCode)")}
                completion(nil)
            }.resume()
        } catch let error {completion("Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }
    
    
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
            DispatchQueue.main.async { (UIApplication.shared.delegate as! AppDelegate).shared.canLoadAroundYouMap = false }
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
    
    static func addRequest(request: Request, completion: @escaping (String?, ErrorString?)-> Void) { // (id, error)
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: Any?] = ["title": request.title, "description": request.descr, "neederID" : CoreDataController.loggedUser!._id, "date": serverDateFormatter(date: request.date), "latitude": request.position.coordinate.latitude , "longitude": request.position.coordinate.longitude]
            let request = initJSONRequest(urlString: ServerRoutes.addRequest, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(nil, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(nil,"Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion(nil,"Response code != 200 in \(#function): \(responseCode)")}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return completion(nil, "Error with returned data in " + #function)}
                let _id = jsonResponse["_id"].stringValue
                completion(_id, nil)
            }.resume()
        } catch let error {completion(nil, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    } //Error handling missing, but should work
    
    static func addRequestOLD(title: String, description: String?, address: String, city: String, date: Date, coordinates: CLLocationCoordinate2D, completion: @escaping (Task?, ErrorString?)-> Void) {
        do {
            print("*** DB - \(#function) ***")
            let parameters: [String: Any?] = ["title": title, "description": description, "neederID" : CoreDataController.loggedUser!._id, "date": serverDateFormatter(date: date), "latitude": coordinates.latitude , "longitude": coordinates.longitude]
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
                sendPushNotification(receiverID: toAccept.neederID, title: "Good news!", body: "Your \(toAccept.title) request has been accepted!")
                completion(nil)
            }.resume()
        } catch let error {completion("Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    } //Error handling missing, but should work
    
    static func removeRequest(toRemove: Task, completion: @escaping (ErrorString?)-> Void) {
        print("*** DB - \(#function) ***")
        removeBond(toRemove: toRemove, isRequest: true, receiverID: toRemove.helperID, completion: completion)
    }
    
    static func removeTask(toRemove: Task, completion: @escaping (ErrorString?)-> Void) {
        print("*** DB - \(#function) ***")
        removeBond(toRemove: toRemove, isRequest: false, receiverID: toRemove.neederID, completion: completion)
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
    
    static func updateProfile(newName: String, newSurname: String, newImageEncoded: String? = nil, completion: @escaping (Int, ErrorString?)-> Void){
        do {
            print("*** DB - \(#function) ***")
            var parameters: [String: Any] = ["_id" : CoreDataController.loggedUser!._id, "name" : newName, "surname" : newSurname]
            if(newImageEncoded != nil) {parameters["photo"] = newImageEncoded}
            let request = initJSONRequest(urlString: ServerRoutes.updateProfile, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion(400, "Error in " + #function + ". The error is:\n\(error!.localizedDescription)")}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion(400, "Error in " + #function + ". Invalid response!")}
                completion(responseCode, responseCode == 400 ? "Server function returned 400" : nil)
            }.resume()
        } catch let error {completion(400, "Error in " + #function + ". The error is:\n" + error.localizedDescription)}
    }
    
    private static func removeBond(toRemove: Task, isRequest: Bool, receiverID: String?, completion: @escaping (ErrorString?)-> Void) {
        do {
            let parameters: [String: String] = ["_id": toRemove._id]
            let request = initJSONRequest(urlString: isRequest ? ServerRoutes.removeRequest : ServerRoutes.removeTask, body: try JSONSerialization.data(withJSONObject: parameters), httpMethod: isRequest ? "DELETE" : "PUT")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {return completion("Error in " + #function + " opering with a \(isRequest ? "request" : "task"). The error is:\n" + error!.localizedDescription)}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {return completion("Error in " + #function + ". Invalid response!")}
                guard responseCode == 200 else {return completion("Invalid response code in \(#function): \(responseCode)")}
                sendPushNotification(receiverID: isRequest ? toRemove.helperID : toRemove.neederID, title: isRequest ? "Don't worry!" : "Oh no! \(CoreDataController.loggedUser!.name) can't help you anymore" , body: isRequest ? "\(CoreDataController.loggedUser!.name) doesn't need your help anymore.\nThanks anyway for your care!" : "Wait for someone else to accept your \(toRemove.title) request." )
                completion(nil)
            }.resume()
        } catch let error {completion("Error in " + #function + " opering with a \(isRequest ? "request" : "task"). The error is:\n" + error.localizedDescription)}
    }
    
    static func updateCathegories(lastUpdate: Date) {
        //Chiede l'ultima data di aggiornamento delle categorie di request al db e, se diversa da quella che ha internamente, richiede al db di inviarle e le aggiorna
        //Apro la connessione, ottengo la data, se diversa faccio la richiesta altrimenti chiudo
    }
    
    static func refreshSignIn(completion: @escaping (String?, String?, String?, CareGiverWeight?, HousewifeWeight?, RunnerWeight?, SmartAssistant?, ErrorString?)->Void){
        do{
            print("*** DB - \(#function) ***")
            let parameters: [String: String?] = ["deviceToken": CoreDataController.deviceToken, "_id": CoreDataController.loggedUser!._id]
            let request = initJSONRequest(urlString: ServerRoutes.signUp, body: try JSONSerialization.data(withJSONObject: parameters))
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {print("Error in " + #function + ". The error is:\n" + error!.localizedDescription); return}
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {print("Error in " + #function + ". The error is:\n" + error!.localizedDescription); return}
                guard responseCode == 200 else {print("Invalid response code in \(#function): \(responseCode)"); return}
                guard let data = data, let jsonResponse = try? JSON(data: data) else {return }
                let name = jsonResponse["name"].string
                let surname = jsonResponse["surname"].string
                let photoURL = jsonResponse["photo"].string
                let caregiver = jsonResponse["caregiver"].doubleValue
                let housewife = jsonResponse["housewife"].doubleValue
                let runner = jsonResponse["runner"].doubleValue
                let smartAssistant = jsonResponse["smartassistant"].doubleValue
                completion(name, surname, photoURL, caregiver, housewife, runner, smartAssistant, nil)
            }.resume()
        } catch{
            print("Error in " + #function + ". The error is:\n" + error.localizedDescription)
        }
    }
    
    private static func sendPushNotification(receiverID: String? ,title: String, body: String){
        guard let receiverID = receiverID else {return}
        do{
            print("*** DB - \(#function) ***")
            print ("Receiver ID: \(receiverID)")
            let parameters: [String: String] = ["receiverID": receiverID, "title": title, "body": body]
            let request = initJSONRequest(urlString: ServerRoutes.sendNotification, body: try JSONSerialization.data(withJSONObject: parameters))
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
            let helperID = current["helperID"].string
            let helperReport = current["helperReport"].string
            let neederReport = current["neederReport"].string
            guard (myID != neederID && myID != helperID) || (myID == neederID && helperReport == nil) || (myID == helperID && neederReport == nil) else {continue}
            let title = current["title"].stringValue
            let descr = current["description"].string
            let date = serverDateFormatter(date: current["date"].stringValue)
            let latitude =  current["latitude"].doubleValue
            let longitude = current["longitude"].doubleValue
            let _id = current["_id"].stringValue
            taskDict[_id] = Task(neederID: neederID, helperID: helperID, title: title, descr: descr, date: date, latitude: latitude, longitude: longitude, _id: _id)
            let user = current["user"].arrayValue.first
            if let user = user {
                let userID = user["_id"].stringValue
                if userDict[userID] == nil {
                    let userName = user["name"].stringValue
                    let userSurname = user["surname"].string
                    let userEmail = user["email"].stringValue
                    let userPhotoURL = URL(string: user["photo"].stringValue)
                    userDict[userID] = User(_id: userID, name: userName, surname: userSurname, email: userEmail, photoURL: userPhotoURL)
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
