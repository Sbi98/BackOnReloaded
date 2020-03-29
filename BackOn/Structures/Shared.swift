//
//  SharedResources.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 14/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

class Shared: ObservableObject {
    @Published var isLocationUpdating = true
    @Published var activeView = "HomeView"
    @Published var mainWindow = "CustomTabView"
    @Published var myTasks: [String:Task] = [:]
    @Published var myDiscoverables: [String:Task] = [:]
    @Published var myRequests: [String:Task] = [:]
    @Published var myExpiredRequests: [String:Task] = [:]
    @Published var users: [String:User] = [:]
    

    func requestETA() {
        for task in myTasks.values {
            task.locate()
            task.requestETA(source: MapController.lastLocation!)
        }
        for task in myRequests.values {
            task.locate()
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
    
    func expiredRequestsArray() -> [Task] {
        return Array(myExpiredRequests.values)
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
            if task.helperID == nil {
                if task.neederID == CoreDataController.loggedUser!._id {
                    myRequests[task._id] = task
                } else {
                    print("loadFromCoreData: inconsistent state for task: \(task)\nMaybe you are trying to add a discoverable!")
                }
            } else {
                if task.helperID == CoreDataController.loggedUser!._id {
                    myTasks[task._id] = task
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
