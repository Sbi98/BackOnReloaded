//
//  s.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 28/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation

struct ServerRoutes {
    private static let baseURL = "https://serverlessbackon.now.sh/api"
    static let signUp = {baseURL+"/signin.js"}()
    //static let getUserByID = {baseURL+"/getUserByID.js"}()
    //static let getBondByID = {baseURL+"/getBondByID.js"}()
    static let getMyBonds = {baseURL+"/getMyBonds.js"}()
    //static let getMyTasks = {baseURL+"/getMyTasks.js"}()
    //static let getMyRequests = {baseURL+"/getMyRequests.js"}()
    static let removeTask = {baseURL+"/cancelTask.js"}()
    static let removeRequest = {baseURL+"/deleteRequest.js"}()
    static let discover = {baseURL+"/discover.js"}()
    static let addRequest = {baseURL+"/addRequest.js"}()
    static let addTask = {baseURL+"/addTask.js"}()
    static let reportTask = {baseURL+"/reportTask.js"}()
}
