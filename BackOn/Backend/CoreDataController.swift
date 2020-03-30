//
//  CoreDataController.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 15/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI


class CoreDataController {
    static var loggedUser: User?
    static var persistentContainer: NSPersistentContainer?
    static var context: NSManagedObjectContext?
    
    static func initController() {
        persistentContainer = NSPersistentContainer(name: "BackOn")
        persistentContainer!.loadPersistentStores(completionHandler: { (_, error) in
            guard error == nil else {fatalError("Unresolved error \(error!)")}
            context = persistentContainer!.newBackgroundContext()
            loggedUser = getLoggedUser()
        })
    }
    
    static func saveContext() throws {
        if context!.hasChanges {
            try context!.save()
        }
    }
    
    static func signUp(user: User) {
        print("*** CD - \(#function) ***")
        let entity = NSEntityDescription.entity(forEntityName: "PLoggedUser", in: context!)
        let newUser = PLoggedUser(entity: entity!, insertInto: context)
        newUser.name = user.name
        newUser.surname = user.surname
        newUser.email = user.email
        newUser.photoURL = user.photoURL
        newUser.id = user._id
        do {
            try saveContext()
        } catch {print("Error while saving \(newUser.name!) in memory! The error is:\n\(error)\n");return}
        print("\(user.name) saved in memory")
        loggedUser = user
    }
    
    static func getLoggedUser() -> User? {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PLoggedUser> = PLoggedUser.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            guard let temp = array.first else {print("User not logged yet"); return nil}
            return User(name: temp.name!, surname: temp.surname, email: temp.email!, photoURL: temp.photoURL!, _id: temp.id!)
        } catch {print("Error while getting logged user: \(error.localizedDescription)");return nil}
    }
    
    static func deleteLoggedUser() {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PLoggedUser> = PLoggedUser.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for loggedUser in array {
                context!.delete(loggedUser)
            }
            try saveContext()
        } catch {print("Error while deleting logged user: \(error.localizedDescription)");return}
    }
    
    static func addUser(user: User, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let entity = NSEntityDescription.entity(forEntityName: "PUsers", in: context!)
        let newUser = PUsers(entity: entity!, insertInto: context!)
        newUser.name = user.name
        newUser.surname = user.surname
        newUser.email = user.email
        newUser.photoURL = user.photoURL
        newUser.id = user._id
        print("\(user)ready to save in memory\n")
        if save {
            do {
                try saveContext()
                print("Saved in memory")
            } catch {print("Error while saving \(newUser.name!) in memory! The error is:\n\(error)\n");return}
        }
    }
    
    static func updateUser(user: User, save: Bool = false) {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PUsers> = PUsers.fetchRequest()
        do {
            fetchRequest.predicate = NSPredicate(format: "id = %@", user._id)
            fetchRequest.returnsObjectsAsFaults = false
            let array = try context!.fetch(fetchRequest)
            guard let cachedUser = array.first else {return}
            cachedUser.setValue(user.name, forKey: "name")
            cachedUser.setValue(user.surname, forKey: "surname")
            cachedUser.setValue(user.photoURL, forKey: "photoURL")
            if save {
                try saveContext()
            }
        } catch {
            print("Errore recupero informazioni dal context \n \(error)")
        }
    }
    
    static func getCachedUsers() -> [User] {
        print("*** CD - \(#function) ***")
        var cachedUsers: [User] = []
        let fetchRequest: NSFetchRequest<PUsers> = PUsers.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for pUser in array {
                cachedUsers.append(User(name: pUser.name!, surname: pUser.surname, email: pUser.email!, photoURL: pUser.photoURL!, _id: pUser.id!))
            }
        } catch {print("Error while getting cached tasks: \(error.localizedDescription)")}
        return cachedUsers
    }
    
    static func deleteUser(user: User, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PUsers> = PUsers.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for pUser in array {
                if pUser.email! == user.email {
                    print("\(user)ready to be deleted from memory\n")
                    context!.delete(pUser)
                }
            }
            if save {
                try saveContext()
                print("Deleted from memory")
            }
        } catch {print("Error while deleting logged user: \(error.localizedDescription)");return}
    }
    
    static func addTask(task: Task, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let entity = NSEntityDescription.entity(forEntityName: "PTasks", in: context!)
        let newTask = PTasks(entity: entity!, insertInto: context)
        newTask.id = task._id
        newTask.title = task.title
        newTask.descr = task.descr
        newTask.date = task.date
        newTask.address = task.address
        newTask.latitude = task.position.coordinate.latitude
        newTask.longitude = task.position.coordinate.longitude
        newTask.helperID = task.helperID
        newTask.neederID = task.neederID
        newTask.mapSnap = task.mapSnap?.pngData()
        print("\(task)ready to save in memory\n")
        if save {
            do {
                try saveContext()
            } catch {print("\nError while saving \(task) in memory! The error is:\n\(error)\n");return}
            print("Saved in memory")
        }
    }
    
    static func updateRequest(request: Task, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PTasks> = PTasks.fetchRequest()
        do {
            fetchRequest.predicate = NSPredicate(format: "id = %@", request._id)
            fetchRequest.returnsObjectsAsFaults = false
            let array = try context!.fetch(fetchRequest)
            guard let cachedTask = array.first else {return}
            cachedTask.setValue(request.helperID, forKey: "helperID")
            if save {
                try saveContext()
            }
        } catch {
            print("Errore recupero informazioni dal context \n \(error)")
        }
    }
    
    static func getCachedTasks() -> [Task] {
        print("*** CD - \(#function) ***")
        var cachedTasks: [Task] = []
        let fetchRequest: NSFetchRequest<PTasks> = PTasks.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for task in array {
                let myTask = Task(neederID: task.neederID!, title: task.title!, descr: task.descr, date: task.date!, latitude: task.latitude, longitude: task.longitude, _id: task.id!)
                if let helperID = task.helperID {myTask.helperID = helperID}
                if let mapSnap = task.mapSnap {
                    myTask.mapSnap = UIImage(data: mapSnap)
                }
                cachedTasks.append(myTask)
            }
        } catch {print("Error while getting cached tasks: \(error.localizedDescription)")}
        return cachedTasks
    }
    
    static func deleteTask(task: Task, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PTasks> = PTasks.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for pTask in array {
                if pTask.id! == task._id {
                    print("\(task)ready to be deleted from memory\n")
                    context!.delete(pTask)
                }
            }
            if save {
                try saveContext()
                print("Deleted from memory\n")
            }
        } catch {print("Error while deleting logged user: \(error.localizedDescription)");return}
    }
    
    static func addTasks(tasks: [Task]) {
        for task in tasks {
            addTask(task: task)
        }
    }
    
//    static func deleteAll() {
//        print("*** CD - \(#function) ***")
//        let fetchRequestTask: NSFetchRequest<PTasks> = PTasks.fetchRequest()
//        let fetchRequestUser: NSFetchRequest<PUsers> = PUsers.fetchRequest()
//        do {
//            let arrayTask = try context!.fetch(fetchRequestTask)
//            let arrayTask = try context!.fetch(fetchRequestTask)
//            for pTask in array {
//                context!.delete(pTask)
//            }
//            try saveContext()
//        } catch {print("Error while deleting logged user: \(error.localizedDescription)");return}
//    }
}
