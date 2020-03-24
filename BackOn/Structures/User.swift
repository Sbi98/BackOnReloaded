//
//  UserInfo.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

class User {
    var photoURL: URL
    var name: String
    var surname: String?
    var identity: String {
        return "\(name) \(surname ?? "")"
    }
    var email: String
    var profilePic: Image?
    private var id: String?
    var ID: String? {
        get{
            return id
        }
        set{
            if id == nil && newValue != nil{
                id = newValue
            }
        }
    }

    
//    Costruttore aggiuntivo utilizzato al momento dell'accesso con Google
    init(name: String, surname: String?, email: String, photoURL: URL) {
        self.name = name
        self.surname = surname
        self.email = email
        self.photoURL = photoURL
    }

    init(name: String, surname: String, email: String, photoURL: URL) {
        self.name = name
        self.surname = surname
        self.email = email
        self.photoURL = photoURL
        do {
            profilePic = try Image(uiImage: UIImage(data: Data(contentsOf: photoURL))!)
        } catch {}
    }
}

let noUser = User(name: "Nobody", surname: "accepted", email: "", photoURL: URL(string: "noUser")!)
