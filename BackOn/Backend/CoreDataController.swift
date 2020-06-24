//
//  CoreDataController.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 15/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI


class CoreDataController {
    static var loggedUser: User?
    static var deviceToken: String?
    static var persistentContainer: NSPersistentContainer?
    static var context: NSManagedObjectContext?
    
    static func initController() {
        persistentContainer = NSPersistentContainer(name: "BackOn")
        persistentContainer!.loadPersistentStores(completionHandler: { (_, error) in
            guard error == nil else {fatalError("Unresolved error \(error!)")}
            context = persistentContainer!.newBackgroundContext()
            loggedUser = getLoggedUser()
            deviceToken = getDeviceToken()
        })
    }
    
    static func saveContext() throws {
        if context!.hasChanges {
            try context!.save()
            print("*** CD - Context saved! ***")
        } else {print("*** CD - Context hasn't got any change! ***")}
    }
    
    static func loadInShared() {
        let cachedUsers = getCachedUsers()
        let cachedBonds = getCachedBonds()
        let today = Date()
        for user in cachedUsers {
            DispatchQueue.main.async {(UIApplication.shared.delegate as! AppDelegate).shared.users[user._id] = user}
        }
        for bond in cachedBonds {
            if bond.neederID == loggedUser!._id { // è una mia request
                if bond.date < today { // è scaduta
                    if bond.date < today.advanced(by: -259200) { // è scaduta da più di 3 giorni
                        deleteBond(bond, save: false)
                    } else { // è scaduta da meno di 3 giorni
                        if bond.address == "Locating..." {bond.locate()}
                        DispatchQueue.main.async {(UIApplication.shared.delegate as! AppDelegate).shared.myExpiredRequests[bond._id] = bond}
                    }
                } else { // è attiva
                    if bond.address == "Locating..." {bond.locate()}
                    DispatchQueue.main.async {(UIApplication.shared.delegate as! AppDelegate).shared.myRequests[bond._id] = bond}
                }
            } else {
                if bond.helperID == loggedUser!._id { // è un mio task
                    if bond.date < today { // è scaduto
                        if bond.date < today.advanced(by: -259200) { // è scaduto da più di 3 giorni
                            deleteBond(bond, save: false)
                        } else { // è scaduto da meno di 3 giorni
                            if bond.address == "Locating..." {bond.locate()}
                            DispatchQueue.main.async {(UIApplication.shared.delegate as! AppDelegate).shared.myExpiredTasks[bond._id] = bond}
                        }
                    } else { // è attivo
                        DispatchQueue.main.async {(UIApplication.shared.delegate as! AppDelegate).shared.myTasks[bond._id] = bond}
                        if bond.address == "Locating..." {bond.locate()}
                        if bond.lightMapSnap == nil || bond.darkMapSnap == nil {
                            MapController.getSnapshot(location: bond.position.coordinate, style: .dark){ snapshot, error in
                                guard error == nil, let snapshot = snapshot else {print("Error while getting dark snapshot in loadInShared");return}
                                DispatchQueue.main.async {bond.darkMapSnap = snapshot.image}
                            }
                            MapController.getSnapshot(location: bond.position.coordinate, style: .light){ snapshot, error in
                                guard error == nil, let snapshot = snapshot else {print("Error while getting light snapshot in loadInShared");return}
                                DispatchQueue.main.async {bond.lightMapSnap = snapshot.image}
                            }
                        }
                    }
                } else {
                    print("\nloadInShared - inconsistent state for\n\(bond)\n")
                    deleteBond(bond, save: false)
                }
            }
        }
        do {
            try saveContext()
        } catch {print("\nError in loadFromCoreData while saving context\n")}
    }
    
    static func saveDeviceToken(deviceToken: String?){
        print("*** CD - \(#function) ***")
        guard let deviceToken = deviceToken, self.deviceToken == nil else {return} // prima era getDeviceToken() == nil
        let entity = NSEntityDescription.entity(forEntityName: "PDeviceToken", in: context!)
        let newToken = PDeviceToken(entity: entity!, insertInto: context)
        newToken.token = deviceToken
        do {
            try saveContext()
            print("\nSaving context from \(#function)\n")
        } catch {print("Error while saving \(newToken.token!) in memory! The error is:\n\(error)\n");return}
        print("Device token \(deviceToken) saved in memory")
        self.deviceToken = deviceToken
    }
    
    static func getDeviceToken() -> String? {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PDeviceToken> = PDeviceToken.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            guard let temp = array.first else {print("Token not saved yet"); return nil}
            let token = temp.token
            print("DeviceToken from CD is " + (token ?? "Token unavailable"))
            return token
        } catch {print("\nError while getting device token: \(error.localizedDescription)\n");return nil}
    }
    
    static func signUp(user: User) {
        print("*** CD - \(#function) ***")
        let entity = NSEntityDescription.entity(forEntityName: "PLoggedUser", in: context!)
        let newUser = PLoggedUser(entity: entity!, insertInto: context)
        newUser.name = user.name
        newUser.surname = user.surname
        newUser.email = user.email
        newUser.photoURL = user.photoURL
        newUser.photoData = user.photo?.jpegData(compressionQuality: 1)
        newUser.id = user._id
        do {
            try saveContext()
            print("\nSaving context from \(#function)\n")
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
            let loggedUser = User(
                _id: temp.id!,
                name: temp.name!,
                surname: temp.surname,
                email: temp.email!,
                photoURL: temp.photoURL,
                photo: temp.photoData == nil ? nil : UIImage(data: temp.photoData!),
                phoneNumber: temp.phoneNumber
            )
            print("\nLogged user is \(loggedUser)")
            return loggedUser
        } catch {print("\nError while getting logged user: \(error.localizedDescription)\n");return nil}
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
            print("\nSaving context from \(#function)\n")
        } catch {print("\nError while deleting logged user: \(error.localizedDescription)\n");return}
    }
    
    static func addUser(user: User, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let entity = NSEntityDescription.entity(forEntityName: "PUsers", in: context!)
        let newUser = PUsers(entity: entity!, insertInto: context!)
        newUser.name = user.name
        newUser.surname = user.surname
        newUser.email = user.email
        newUser.photoURL = user.photoURL
        newUser.photoData = user.photo?.jpegData(compressionQuality: 1)
        newUser.id = user._id
        newUser.phoneNumber = user.phoneNumber
        print("\n\(user)ready to save in memory\n")
        if save {
            do {
                try saveContext()
                print("Saved in memory")
            } catch {print("\nError while saving \(newUser.name!) in memory! The error is:\n\(error)\n");return}
        }
    }
    
    static func updateUser(user: User, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PUsers> = PUsers.fetchRequest()
        do {
            fetchRequest.predicate = NSPredicate(format: "id = %@", user._id)
            fetchRequest.returnsObjectsAsFaults = false
            let array = try context!.fetch(fetchRequest)
            guard let cachedUser = array.first else {return}
            cachedUser.setValue(user.name, forKey: "name")
            cachedUser.setValue(user.surname, forKey: "surname")
            cachedUser.setValue(user.photo?.jpegData(compressionQuality: 1), forKey: "photoData")
            cachedUser.setValue(user.photoURL, forKey: "photoURL")
            cachedUser.setValue(user.phoneNumber, forKey: "phoneNumber")
            if save {
                try saveContext()
                print("\nSaving context from \(#function)\n")
            }
        } catch {print("\nErrore recupero informazioni dal context \n \(error)\n")}
    }
    
    static func updateLoggedUser(user: User, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PLoggedUser> = PLoggedUser.fetchRequest()
        do {
            fetchRequest.predicate = NSPredicate(format: "id = %@", user._id)
            fetchRequest.returnsObjectsAsFaults = false
            let array = try context!.fetch(fetchRequest)
            guard let cachedUser = array.first else {return}
            if cachedUser.name != user.name {cachedUser.setValue(user.name, forKey: "name")}
            if cachedUser.surname != user.surname {cachedUser.setValue(user.surname, forKey: "surname")}
            if cachedUser.photoData != user.photo?.jpegData(compressionQuality: 1) {cachedUser.setValue(user.photo?.jpegData(compressionQuality: 1), forKey: "photoData")}
            if cachedUser.photoURL != user.photoURL {cachedUser.setValue(user.photoURL, forKey: "photoURL")}
            if cachedUser.phoneNumber != user.phoneNumber {cachedUser.setValue(user.phoneNumber, forKey: "phoneNumber")}
            if save {
                try saveContext()
            }
        } catch {print("\nErrore recupero informazioni dal context \n \(error)\n")}
    }
    
    static func getCachedUsers() -> [User] {
        print("*** CD - \(#function) ***")
        var cachedUsers: [User] = []
        let fetchRequest: NSFetchRequest<PUsers> = PUsers.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for pUser in array {
                cachedUsers.append(User(
                    _id: pUser.id!,
                    name: pUser.name!,
                    surname: pUser.surname,
                    email: pUser.email!,
                    photoURL: pUser.photoURL!,
                    photo: pUser.photoData == nil ? nil : UIImage(data: pUser.photoData!),
                    phoneNumber: pUser.phoneNumber
                ))
            }
        } catch {print("\nError while getting cached tasks: \(error.localizedDescription)\n")}
        return cachedUsers
    }
    
    static func deleteUser(user: User, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PUsers> = PUsers.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for pUser in array {
                if pUser.email! == user.email {
                    print("\n\(user)ready to be deleted from memory\n")
                    context!.delete(pUser)
                }
            }
            if save {
                try saveContext()
                print("Deleted from memory")
            }
        } catch {print("\nError while deleting logged user: \(error.localizedDescription)\n");return}
    }
    
    static func addBond(_ bond: Bond, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let entity = NSEntityDescription.entity(forEntityName: "PTasks", in: context!)
        let newTask = PTasks(entity: entity!, insertInto: context)
        newTask.id = bond._id
        newTask.title = bond.title
        newTask.descr = bond.descr
        newTask.date = bond.date
        newTask.address = bond.address
        newTask.city = bond.city
        newTask.latitude = bond.position.coordinate.latitude
        newTask.longitude = bond.position.coordinate.longitude
        newTask.helperID = bond.helperID
        newTask.neederID = bond.neederID
        newTask.lightMapSnap = bond.lightMapSnap?.pngData()
        newTask.darkMapSnap = bond.darkMapSnap?.pngData()
        print("\n\(bond)ready to save in memory\n")
        if save {
            do {
                try saveContext()
                print("Saved in memory")
            } catch {print("\nError while saving \(bond) in memory! The error is:\n\(error)\n");return}
        }
    }
    
    static func updateRequest(_ request: Request, save: Bool = true) {
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
                print("\nSaving context from \(#function)\n")
            }
        } catch {
            print("\nErrore recupero informazioni dal context \n \(error)\n")
        }
    }
    
    static func getCachedBonds() -> [Bond] {
        print("*** CD - \(#function) ***")
        var cachedBonds: [Bond] = []
        let fetchRequest: NSFetchRequest<PTasks> = PTasks.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for bond in array {
                cachedBonds.append(Bond(
                    neederID: bond.neederID!,
                    helperID: bond.helperID,
                    title: bond.title!,
                    descr: bond.descr,
                    date: bond.date!,
                    latitude: bond.latitude,
                    longitude: bond.longitude,
                    _id: bond.id!,
                    lightMapSnap: bond.lightMapSnap == nil ? nil : UIImage(data: bond.lightMapSnap!),
                    darkMapSnap: bond.darkMapSnap == nil ? nil : UIImage(data: bond.darkMapSnap!),
                    address: bond.address,
                    city: bond.city)
                )
            }
        } catch {print("\nError while getting cached tasks: \(error.localizedDescription)\n")}
        return cachedBonds
    }
    
    static func deleteBond(_ bond: Bond, save: Bool = true) {
        print("*** CD - \(#function) ***")
        let fetchRequest: NSFetchRequest<PTasks> = PTasks.fetchRequest()
        do {
            let array = try context!.fetch(fetchRequest)
            for pBond in array {
                if pBond.id! == bond._id {
                    print("\n\(bond)ready to be deleted from memory\n")
                    context!.delete(pBond)
                }
            }
            if save {
                try saveContext()
                print("\(bond)deleted from memory\n")
            }
        } catch {print("\nError while deleting bond: \(error.localizedDescription)\n")}
    }

    static func deleteAll() {
        print("*** CD - \(#function) ***")
        deleteAllData(entity: "PLoggedUser")
        deleteAllData(entity: "PTasks")
        deleteAllData(entity: "PUsers")
        print("Everything deleted from CD")
    }
    
    private static func deleteAllData(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context!.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                context!.delete(managedObjectData)
            }
            try saveContext()
        } catch {print("Error while deleting all data in \(entity): \(error)")}
    }

    
}
