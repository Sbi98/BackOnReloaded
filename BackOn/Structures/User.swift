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
    var isHelper: Int?

    
//    Costruttore aggiuntivo utilizzato al momento dell'accesso con Google
    init(name: String, surname: String?, email: String, photoURL: URL) {
        self.name = name
        self.surname = surname
        self.email = email
        self.photoURL = photoURL
    }

    init(name: String, surname: String, email: String, photoURL: URL, isHelper: Int) {
        self.name = name
        self.surname = surname
        self.email = email
        self.photoURL = photoURL
        self.isHelper = isHelper
        do {
            profilePic = try Image(uiImage: UIImage(data: Data(contentsOf: photoURL))!)
        } catch {}
    }
}
