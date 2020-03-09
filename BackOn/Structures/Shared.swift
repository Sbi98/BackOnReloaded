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
                myRequests = [:]
                (UIApplication.shared.delegate as! AppDelegate).dbController.loadCommitByOther()
                (UIApplication.shared.delegate as! AppDelegate).dbController.loadMyCommitments()
                (UIApplication.shared.delegate as! AppDelegate).dbController.getCommitByUser()
                self.loading = false
            }
        }
    }
    
    @Published var activeView = "HomeView"
    @Published var mainWindow = "LoadingPageView"
    @Published var selectedCommitment = Task()
    @Published var myTasks: [Int:Task] = [:]
    @Published var myDiscoverables: [Int:Task] = [:]
    @Published var myRequests: [Int:Task] = [:]

    
    func commitmentArray() -> [Task] {
        return Array(myTasks.values)
    }
    
    func needArray() -> [Task] {
        return Array(myRequests.values)
    }
    
    func discoverArray() -> [Task] {
        return Array(myDiscoverables.values)
    }
    
    func loadFromCoreData() {
        let tasks = CoreDataController.getCachedTasks()
        for task in tasks {
            if task.helperUser == nil {
                if task.neederUser.email == CoreDataController.loggedUser!.email {
                    myRequests[task.ID] = task
                } else {
                    myDiscoverables[task.ID] = task
                }
            } else {
                if task.helperUser!.email == CoreDataController.loggedUser!.email {
                    myTasks[task.ID] = task
                } else {
                    print("loadFromCoreData: inconsistent state for task: \(task)")
                }
            }
        }
    }
}



    
//    private static var formatter = DateFormatter()
//    var dateFormatter: DateFormatter{
//        get{
//            Shared.formatter.dateFormat = "MMM dd, yyyy  HH:mm"
//            return Shared.formatter
//        }
//    }
//    @Published var neederInfo: User?
    
