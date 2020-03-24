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
    private static let mainRoute = "https://8d5da3a1.ngrok.io/api"
    private static let signupRoute = "/auth/signin"
    private static let getUserByIdRoute = "/auth/getUserByID"
    private static let getBondByIdRoute = "/tasks/bond"
    private static let getBondsRoute = "/tasks/getTasks"
    private static let removeTaskRoute = "/tasks/cancelTask"
    private static let removeRequestRoute = "/tasks/deleteRequest"
    private static let discoverRoute = "/tasks/discover"
    private static let addRequestRoute = "/tasks/addRequest"
    private static let addTaskRoute = "/tasks/addTask"
    
    static func signUp() -> String{
        return mainRoute + signupRoute
    }
    static func getUserByID () -> String{
        return mainRoute + getUserByIdRoute
    }
    static func getBondByID(id: String) -> String{
//        print("\n\n\n" + id)
        return mainRoute + getBondByIdRoute + "/" + id
    }
    static func getBonds () -> String{
        return mainRoute + getBondsRoute
    }
    static func removeTasks(id: String) -> String{
        return mainRoute + removeTaskRoute + "/" + id
    }
    static func removeRequest (id: String) -> String{
        return mainRoute + removeRequestRoute + "/" + id
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

var users: [String:User] = [:]
let serverDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter
}()

struct DatabaseController {
    static let serverIPandPort = "backon.serverless.social/api/auth"
    static let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    //    MARK: SignUp
    //    Updating the current user and adding it to the databbase if absent
    static func signUp(newUser: User, completion: @escaping ()-> Void) {
        print("createNewUser")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters: [String: String] = ["name": newUser.name, "surname": newUser.surname ?? "", "email" : newUser.email, "photo": "\(newUser.photoURL)"]
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: ServerRoutes.signUp())!)
        request.httpMethod = "POST" //set http method as POST
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print("Client error: " + error.localizedDescription)
        }
        let start = DispatchTime.now() // <<<<<<<<<< Start time
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSON(data: data){
                    let userID = jsonResponse["_id"].stringValue
                    print("new user.id = \(newUser.ID ?? "nil")\n user id ottenuto: \(userID)")
                    if newUser.ID == nil || newUser.ID == userID {
                        newUser.ID = userID
                        print("Arrivo ad assegnare l'ID")
//                        CoreDataController.addUser(user: newUser)
                        print("Ho salvato l'utente!")
                        
                        users[newUser.ID!] = newUser
                        ///ATTENZIONE! ANDREE RESA LA CONNESSIONE PERSISTENTE E FATTO IN MODO CHE REQUESTS E TASKS LA PRENDANO
//                        getRequests()
//                        getTasks()
                    
                        completion()
                    }
                    //Chiamata alle funzioni di fetch dei task e delle request dell'utente
                }
            }
        }.resume()
        
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
    
    //MARK: GetUserByID
    //Get a user from its id
    static func getUserByID(id: String){
        print("getUserByID")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters: [String: String] = ["_id": id]
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: ServerRoutes.getUserByID())!)
        request.httpMethod = "POST" //set http method as POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        //create dataTask using the session object to send data to the server
        
        //Next method is to get rerver response
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSON(data: data){
                    let name = jsonResponse["name"].stringValue
                    let email = jsonResponse["email"].stringValue
                    let surname = jsonResponse["surname"].stringValue
                    let photoURL = URL(string: jsonResponse["photo"].stringValue)!
                    print("\n\n\nUSER")
                    print(jsonResponse)
                    users[id] = User(name: name, surname: surname, email: email, photoURL: photoURL)
                    users[id]!.ID = id
                }
            }
        }.resume()
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
    
    //MARK: GetBondByID
    //Get a user's request or task from its id
    static func getBondByID(id: String){
        print("getBondByID")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: ServerRoutes.getBondByID(id: id))!)
        request.httpMethod = "GET" //set http method as POST
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        
        //Next method is to get rerver response
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSON(data: data){
                    print("Ci entro!")
                    let neederID = jsonResponse["neederID"].stringValue
                    let title = jsonResponse["title"].stringValue
                    let descr = jsonResponse["description"].stringValue
//                    let date = serverDateFormatter.date(from: jsonResponse["date"].stringValue)!
                    let date = Date()
                    let latitude =  jsonResponse["latitude"].doubleValue
                    let longitude = jsonResponse["longitude"].doubleValue
                    let ID = jsonResponse["_id"].stringValue
                    let helperID = jsonResponse["helperID"].stringValue
                    
                    let newBond:Task = Task(neederID: neederID, title: title, descr: descr == "" ? nil : descr, date: date, latitude: latitude, longitude: longitude, ID: ID)
                    newBond.helperID = helperID == "" ? nil : helperID
                    if neederID == CoreDataController.loggedUser!.ID! {shared.myRequests[ID] = newBond; if newBond.helperID != nil && users[newBond.helperID!] == nil {getUserByID(id: newBond.helperID!)}}
                    else if helperID == CoreDataController.loggedUser!.ID!{shared.myTasks[ID] = newBond; if users[newBond.neederID] == nil {getUserByID(id: newBond.neederID)}}
                    print("\n\nBOND SCARICATO:")
                    print(newBond)
                }
            }
        }.resume()
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
    
    //MARK: GetTasks
    //Get a user's task' ids and, if absent, adds it into the database
    static func getTasks(){
        print("getTasks")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters: [String: String] = ["helperID": CoreDataController.loggedUser!.ID!]
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: ServerRoutes.getBonds())!)
        request.httpMethod = "POST" //set http method as POST
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        
        //Next method is to get rerver response
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonArray = try? JSON(data: data){
                    var idSet: Set<String> = []
                    for (_,task):(String, JSON) in jsonArray {
                        let taskID = task["_id"].stringValue
                        idSet.insert(taskID)
                        if shared.myTasks[taskID] == nil {getBondByID(id: taskID)}
                    }
                    for taskID in shared.myTasks.keys {
                        if !idSet.contains(taskID) {shared.myTasks[taskID] = nil}
                    }
                }
            }
        }.resume()
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
    
    //MARK: GetRequests
    //Get a user's task' ids
    static func getRequests(){
        print("getRequests")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters: [String: String] = ["neederID": CoreDataController.loggedUser!.ID!]
        print(parameters)
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: ServerRoutes.getBonds())!)
        request.httpMethod = "POST" //set http method as POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        
        //create dataTask using the session object to send data to the server
        
        //Next method is to get rerver response
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonArray = try? JSON(data: data){
                    var idSet: Set<String> = []
                    for (_,request):(String, JSON) in jsonArray {
                        let requestID = request["_id"].stringValue
                        idSet.insert(requestID)
                        print("\n\nrequest id ottenuto nella get requests: " + requestID)
                        if shared.myRequests[requestID] == nil {getBondByID(id: requestID)}
                        for requestID in shared.myRequests.keys {
                            if !idSet.contains(requestID) {shared.myRequests[requestID] = nil}
                        }
                    }
                }
            }
        }.resume()
    }  ///FINITA, GESTIONE DELL'ERRORE DA FARE
    
    //MARK: AddRequest
    //Adding a request from current user
    static func addRequest(newRequest: Task){
        print("addRequest")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters: [String: Any] = ["title": newRequest.title, "description": newRequest.descr ?? "" , "neederID" : newRequest.neederID, "date": serverDateFormatter.string(from: newRequest.date), "latitude": newRequest.position.coordinate.latitude , "longitude": newRequest.position.coordinate.longitude]
        print(parameters)
        
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: ServerRoutes.addRequest())!)
        request.httpMethod = "POST" //set http method as POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        
        //create dataTask using the session object to send data to the server
        
        //Next method is to get rerver response
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("DATA:\n" + "\(data)")
            print("\n\nRESPONSE:\n" + "\(response)")
            guard error == nil else {return}
            if let data = data {
                if let jsonResponse = try? JSON(data: data){
                    let id = jsonResponse["requestID"].stringValue
                    newRequest.ID = id
                    shared.myRequests[id] = newRequest
                }
                
            }
        }.resume()
    } //Error handling missing, but should work
    
    //MARK: AddTask
    //Adding a task for current user
    static func addTask(newTask: Task){
        print("addTask")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters: [String: String] = ["_id": newTask.ID!, "helperID": CoreDataController.loggedUser!.ID!]
        print(parameters)
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: ServerRoutes.addTask())!)
        request.httpMethod = "PUT" //set http method as POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        
        //create dataTask using the session object to send data to the server
        
        //Next method is to get rerver response
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(data)
            print(request)
            print(error)
            guard error == nil else {return}
            if let responseCode = (response as? HTTPURLResponse)?.statusCode {
            guard responseCode == 200 else {
                print("Invalid response code: \(responseCode)")
                return
            }
            }
            print("CI SONOOOO")
            shared.myTasks[newTask.ID!] = newTask
//            if let data = data {
//                if let jsonResponse = try? JSON(data: data){
//                    print(jsonResponse)
//                    let id = jsonResponse["taskID"].stringValue
//                    if id == newTask.ID{
//                        newTask.helperID = CoreDataController.loggedUser!.ID!
//                    shared.myTasks[newTask.ID!] = newTask
//                    }else{print("Something went wrong in adding task, inconsistency between coredata and DB")
//                        print("id ottenuto= \(id)\nid in possesso = \(newTask.ID!)")
//                    }
                
//            }
        }.resume()
    } //Error handling missing, but should work
    
    //MARK: RemoveRequest
    //Removes a request by its ID
    static func removeRequest(requestID: String){
        removeBond(idToRemove: requestID, isRequest: true)
    }
    
    //MARK: RemoveTask
    //Removes a task by its ID
    static func removeTask(taskID: String){
        removeBond(idToRemove: taskID, isRequest: false)
    }
    
    private static func removeBond(idToRemove: String, isRequest: Bool){
        print("removeBond")
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters: [String: String] = ["_id": idToRemove]
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: isRequest ? ServerRoutes.removeRequest(id: idToRemove) : ServerRoutes.removeTasks(id: idToRemove))!)
        request.httpMethod = isRequest ? "DELETE" : "PUT" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        
        //Next method is to get rerver response
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {return}
            if let data = data {
                if (try? JSON(data: data)) != nil{
                    isRequest ? (shared.myRequests[idToRemove] = nil) : (shared.myTasks[idToRemove] = nil)
                }
            }
            
        }.resume()
    }
    
    static func updateCathegories(lastUpdate: Date){
        //Chiede l'ultima data di aggiornamento delle categorie di request al db e, se diversa da quella che ha internamente, richiede al db di inviarle e le aggiorna
        //Apro la connessione, ottengo la data, se diversa faccio la richiesta altrimenti chiudo
    }
    
    static func discover(){
        print("discover")
        let parameters: [String: String] = ["neederID": CoreDataController.loggedUser!.ID!]
        print(CoreDataController.loggedUser!.ID!)
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: ServerRoutes.discover())!)
        request.httpMethod = "POST" //set http method as GET
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        //create dataTask using the session object to send data to the server
        
        //Next method is to get rerver response
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {return}
            if let data = data {
                if let jsonArray = try? JSON(data: data){
                    for (_,discoverable):(String, JSON) in jsonArray {
                        let neederID = discoverable["neederID"].stringValue
                        let title = discoverable["title"].stringValue
                        let descr = discoverable["description"].string
                        let date = Date()
//                            serverDateFormatter.date(from: discoverable["date"].stringValue)!
                        let latitude =  discoverable["latitude"].doubleValue
                        let longitude = discoverable["longitude"].doubleValue
                        let ID = discoverable["_id"].stringValue
                        let helperID = discoverable["helperID"].string
                        print("\n\n\nAO CI ARRIVO")
                        print(discoverable)
                        if helperID == nil{
                            if users[neederID] == nil {getUserByID(id: neederID)}
                            shared.myDiscoverables[ID] = Task(neederID: neederID, title: title, descr: descr, date: date, latitude: latitude, longitude: longitude, ID: ID)
                            print(shared.myDiscoverables[ID])
                        }
                    }
                }
            }
        }.resume()
    }
    
    
}

