//
//  SharedResources.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 14/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI

class Shared: ObservableObject {
    @Published var activeView = "HomeView"
    @Published var mainWindow = "CustomTabView"
    @Published var canLoadAroundYouMap = false
    @Published var profileUpdated = false
    @Published var myTasks: [String:Task] = [:]
    @Published var myExpiredTasks: [String:Task] = [:]
    @Published var myDiscoverables: [String:Task] = [:]
    @Published var myRequests: [String:Task] = [:]
    @Published var myExpiredRequests: [String:Task] = [:]
    @Published var users: [String:User] = [:]
    @Published var discUsers: [String:User] = [:]
    @Published var openingMaps: Date?

    func requestTasksETA() {
        for task in myTasks.values {
            if task.etaText == "Calculating..." {
                task.requestETA()
            }
        }
    }
    
    func requestDiscoverablesETA() {
        for task in myDiscoverables.values {
            if task.etaText == "Calculating..." {
                task.requestETA()
            }
        }
    }
    
    func tasksArray() -> [Task] {
        return Array(myTasks.values)
    }
    
    func expiredTasksArray() -> [Task] {
        return Array(myExpiredTasks.values)
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
    
    func arrayFromSet(mode: RequiredBy, expiredSet: Bool = false) -> [Bond] {
        var toReturn: [Task]
        if mode == .TaskViews {
            toReturn = expiredSet ? expiredTasksArray() : tasksArray()
        } else if mode == .RequestViews {
            toReturn = expiredSet ? expiredRequestsArray() : requestsArray()
        } else {
            return discoverablesArray().sorted { (task1, task2) -> Bool in
                return task1.suitability > task2.suitability
            }
        }
        return toReturn.sorted(by: { (task1, task2) -> Bool in
            if task1.date < Date() && task2.date >= Date(){
                return false
            }
            if task2.date < Date() && task1.date >= Date(){
                return true
            }
            return task1.date<task2.date
        })
    }
    
    func deleteAll(){
        myTasks = [:]
        myExpiredTasks = [:]
        myDiscoverables = [:]
        myRequests = [:]
        myExpiredRequests = [:]
        users = [:]
        discUsers = [:]
        openingMaps = nil
    }
}
