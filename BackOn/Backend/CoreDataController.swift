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
    
    static func initController() {
        loggedUser = getLoggedUser()
        if loggedUser == nil {
            (UIApplication.shared.delegate as! AppDelegate).shared.mainWindow = "LoginPageView"
        } else {
            (UIApplication.shared.delegate as! AppDelegate).shared.mainWindow = "CustomTabView"
            DatabaseController.loadFromServer()
        }
    }
    
 static func signup(user: User) { // save to CoreData
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
     let entity = NSEntityDescription.entity(forEntityName: "PLoggedUser", in: context)
     let newUser = PLoggedUser(entity: entity!, insertInto: context)
     newUser.name = user.name
     newUser.surname = user.surname
     newUser.email = user.email
     newUser.photoURL = user.photoURL
     newUser.id = user._id
     do {
        
         try context.save()
     } catch {
         print("Error while saving \(newUser.name!) in memory! The error is:\n\(error)\n")
         return
     }
     print("\(user.name) saved in memory")
     loggedUser = user
 }
 
 static func addUser(user: User) { // save to CoreData
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
     let entity = NSEntityDescription.entity(forEntityName: "PUsers", in: context)
     let newUser = PUsers(entity: entity!, insertInto: context)
     newUser.name = user.name
     newUser.surname = user.surname
     newUser.email = user.email
     newUser.photoURL = user.photoURL
     newUser.id = user._id
     do {
         try context.save()
     } catch {
         print("Error while saving \(newUser.name!) in memory! The error is:\n\(error)\n")
         return
     }
     print("\(user.name) saved in memory")
 }
    
    static func getLoggedUser() -> User? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<PLoggedUser> = PLoggedUser.fetchRequest()
        do {
            let array = try context.fetch(fetchRequest)
            guard let temp = array.first else {print("User not logged yet"); return nil}
            return User(name: temp.name!, surname: temp.surname, email: temp.email!, photoURL: temp.photoURL!, _id: temp.id!)
        } catch let error {
            print("Error while getting logged user: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func deleteLoggedUser() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<PLoggedUser> = PLoggedUser.fetchRequest()
        do {
            let array = try context.fetch(fetchRequest)
            for loggedUser in array {
                context.delete(loggedUser)
            }
            try context.save()
        } catch let error {
            print("Error while deleting logged user: \(error.localizedDescription)")
            return
        }
    }
    
    static func deleteUser(user: User) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<PUsers> = PUsers.fetchRequest()
        do {
            let array = try context.fetch(fetchRequest)
            for loggedUser in array {
                if loggedUser.email! == user.email {
                    context.delete(loggedUser)
                }
            }
            try context.save()
        } catch let error {
            print("Error while deleting logged user: \(error.localizedDescription)")
            return
        }
    }
    
    static func addTask(task: Task) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "PTasks", in: context)
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
        
        do {
            try context.save()
        } catch {
            print("Error while saving task with id \(newTask.id ?? "NIL") in memory! The error is:\n\(error)\n")
            return
        }
        print("Task \(newTask) saved in memory")
    }
    
    static func addTasks(tasks: [Task]) {
        for task in tasks {
            addTask(task: task)
        }
    }
    
    static func getCachedTasks() -> [Task] {
        var cachedTasks: [Task] = []
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<PTasks> = PTasks.fetchRequest()
        do {
            let array = try context.fetch(fetchRequest)
            for task in array {
                
                let myTask = Task(neederID: task.neederID!, title: task.title!, descr: task.descr, date: task.date!, latitude: task.latitude, longitude: task.longitude, _id: task.id!)
                if let helperID = task.helperID {myTask.helperID = helperID}
               
                if let mapSnap = task.mapSnap {
                    myTask.mapSnap = UIImage(data: mapSnap)
                }
                cachedTasks.append(myTask)
            }
        } catch let error {
            print("Error while getting logged user: \(error.localizedDescription)")
        }
        return cachedTasks
    }
}


//static func userIsLogged() -> Bool {
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    let fetchRequest: NSFetchRequest<PUsers> = PUsers.fetchRequest()
//    do {
//        let array = try context.fetch(fetchRequest)
//        return !array.isEmpty
//    } catch let error {
//        print("PUsers fetchRequest error: \(error.localizedDescription)")
//        return false
//    }
//}
