//
//  CoreDataController.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 15/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataController {
    static let shared = CoreDataController()
    private var context: NSManagedObjectContext
    
    init() {
        let application = UIApplication.shared.delegate as! AppDelegate
        self.context = application.persistentContainer.viewContext
    }
    
    func addUser(user: UserInfo) { // save to CoreData
        let entity = NSEntityDescription.entity(forEntityName: "PUser", in: self.context)
        let newUser = PUser(entity: entity!, insertInto: self.context)
        newUser.name = user.name
        newUser.surname = user.surname
        newUser.email = user.email
        newUser.photo = user.photo
        
        do {
            try self.context.save()
        } catch let errore {
            print("Error in saving: \(newUser.name!) in memoria")
            print("  Stampo l'errore: \n \(errore) \n")
        }
        print("\(newUser.name!) salvato in memoria.")
        
    }
    
    func userIsLogged() -> Bool{
        let fetchRequest: NSFetchRequest<PUser> = PUser.fetchRequest()
        do {
            let array = try self.context.fetch(fetchRequest)
            guard array.count > 0 else {
                print("User not logged yet")
                return false
            }
            return true
        } catch let error {
            print("PUser fetchRequest error: \(error.localizedDescription)")
            return false
        }
    }
    
    func getLoggedUser() -> (String, UserInfo){
        let fetchRequest: NSFetchRequest<PUser> = PUser.fetchRequest()
        do {
            let array = try self.context.fetch(fetchRequest)
            guard array.count > 0 else {
                print("User not logged yet")
                return ("Nil", UserInfo(photo: URL(string: "")!, name: "", surname: "", email: ""))
            }
            let myUser = UserInfo(photo: array[0].photo!, name: array[0].name!, surname: array[0].surname!, email: array[0].email!)
            return ("OK", myUser)
        } catch let error {
            print("Error while getting logged user: \(error.localizedDescription)")
            return ("Nil", UserInfo(photo: URL(string: "")!, name: "", surname: "", email: ""))
        }
    }
    
    func deleteUser(user: UserInfo) {
        let fetchRequest: NSFetchRequest<PUser> = PUser.fetchRequest()
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                if object.email! == user.email {
                    context.delete(object)
                }
            }
            do {
                try context.save()
            }
            catch let error as NSError{
                print("Errore nel salvataggio del contesto: \(error.code)")
            }
        }
    }
    
}
