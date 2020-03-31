//
//  SharedResources.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 14/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

class Shared: ObservableObject {
    @Published var activeView = "HomeView"
    @Published var mainWindow = "CustomTabView"
    @Published var myTasks: [String:Task] = [:]
    @Published var myDiscoverables: [String:Task] = [:]
    @Published var myRequests: [String:Task] = [:]
    @Published var myExpiredRequests: [String:Task] = [:]
    @Published var users: [String:User] = [:]
    @Published var discUsers: [String:User] = [:]
    

    func requestTasksETA() {
        for task in myTasks.values {
            if task.etaText != "Calculating..." {
                task.requestETA()
            }
        }
    }
    
    func requestDiscoverablesETA() {
        for task in myDiscoverables.values {
            if task.etaText != "Calculating..." {
                task.requestETA()
            }
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
    
}
