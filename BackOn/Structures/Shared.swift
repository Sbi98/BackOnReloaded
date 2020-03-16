//
//  SharedResources.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 14/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

class Shared: ObservableObject {
    @Published var loading: Bool = false {
        didSet {
            if oldValue == false && loading == true {
                (UIApplication.shared.delegate as! AppDelegate).shared.mainWindow = "LoadingPageView"
                myDiscoverables = [:]
                myTasks = [:]
//                myRequests = [:]
                (UIApplication.shared.delegate as! AppDelegate).dbController.loadCommitByOther()
                (UIApplication.shared.delegate as! AppDelegate).dbController.loadMyCommitments()
                (UIApplication.shared.delegate as! AppDelegate).dbController.getCommitByUser()
                self.loading = false
            }
        }
    }
    @Published var isLocationUpdating = true
    @Published var activeView = "HomeView"
    @Published var mainWindow = "LoadingPageView"
    @Published var myTasks: [Int:Task] = [:]
    @Published var myDiscoverables: [Int:Task] = [:]
    @Published var myRequests: [Int:Task] = [1:Task(neederUser: User(name: "MioNome", surname: "MioCognome", email: "giovannifalzone@gmail.com", photoURL: URL(string: "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3400&q=80")!), title: "Wheelchair transport", descr: "Sono un po' scemo e mi non ho le gambe ho bisogno di aiuto.", date: Date(), latitude: 41.5, longitude: 15, ID: 1)]

    func requestETA() {
        for task in myTasks.values {
            task.locate()
            task.requestETA(source: MapController.lastLocation!)
        }
        for task in myDiscoverables.values {
            task.locate()
            task.requestETA(source: MapController.lastLocation!)
        }
    }
    
    func tasksArray() -> [Task] {
        return Array(myTasks.values)
    }
    
    func requestsArray() -> [Task] {
        return Array(myRequests.values)
    }
    
    func discoverablesArray() -> [Task] {
        return Array(myDiscoverables.values)
    }
    
    func arrayFromSet(mode: RequiredBy) -> [Task] {
        if mode == .TaskViews {
            return tasksArray()
        } else if mode == .RequestViews {
            return requestsArray()
        } else {
            return discoverablesArray()
        }
    }
    
    func loadFromCoreData() {
        let tasks = CoreDataController.getCachedTasks()
        for task in tasks {
            if task.helperUser == nil {
                if task.neederUser.email == CoreDataController.loggedUser!.email {
                    myRequests[task.ID] = task
                } else {
                    print("loadFromCoreData: inconsistent state for task: \(task)\nMaybe you are trying to add a discoverable!")
                }
            } else {
                if task.helperUser!.email == CoreDataController.loggedUser!.email {
                    myTasks[task.ID] = task
                } else {
                    print("loadFromCoreData: inconsistent state for task: \(task)\nMaybe you are adding a task with a helperUser that isn't you!")
                }
            }
        }
    }
    
    func saveToCoreData() {
        CoreDataController.addTasks(tasks: requestsArray())
        CoreDataController.addTasks(tasks: tasksArray())
    }
}
