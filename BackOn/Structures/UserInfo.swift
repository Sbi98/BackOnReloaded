//
//  UserInfo.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import Foundation
import SwiftUI

class UserInfo {
    var photo: URL
    var name: String
    var surname: String
    var identity: String {
        return "\(name) \(surname)"
    }
    var email: String?
    var profilePic: Image?
    var isHelper: Int?
    
    init(photo: URL, name: String, surname: String) {
        self.photo = photo
        self.name = name
        self.surname = surname
    }
    
//    Costruttore aggiuntivo utilizzato al momento dell'accesso con Google
    init(photo: URL, name: String, surname: String, email: String) {
        self.photo = photo
        self.name = name
        self.surname = surname
        self.email = email
    }

    init(name: String, surname: String, email: String, photoURL: URL, isHelper: Int) {
        self.photo = photoURL
        self.name = name
        self.surname = surname
        self.email = email
        self.isHelper = isHelper
        do {
            profilePic = try Image(uiImage: UIImage(data: Data(contentsOf: photoURL))!)
        } catch {}
    }
}
