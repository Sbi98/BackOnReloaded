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
                if helperMode{
                    discoverSet = [:]
                    taskSet = [:]
                    (UIApplication.shared.delegate as! AppDelegate).dbController.loadCommitByOther()
                    (UIApplication.shared.delegate as! AppDelegate).dbController.loadMyCommitments()
                } else {
                    requestSet = [:]
                    (UIApplication.shared.delegate as! AppDelegate).dbController.getCommitByUser()
                }
                self.loading = false
            }
        }
    }
    @Published var loggedUser: User?
    @Published var previousView = "HomeView"
    @Published var viewToShow = "HomeView"
    @Published var mainWindow = "LoadingPageView"
    @Published var selectedTab = 0
    @Published var selectedCommitment = Task()
    @Published var taskSet: [Int:Task] = [:]
    @Published var discoverSet: [Int:Task] = [:]
    @Published var requestSet: [Int:Task] = [:]
    @Published var helperMode = true
    
    @Published var fullDiscoverViewMode = 0

    
    func commitmentArray() -> [Task] {
        return Array(taskSet.values)
    }
    
    func needArray() -> [Task] {
        return Array(requestSet.values)
    }
    
    func discoverArray() -> [Task] {
        return Array(discoverSet.values)
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
    
