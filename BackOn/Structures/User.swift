//
//  UserInfo.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

class User: ObservableObject, CustomStringConvertible {
    var photoURL: URL
    var name: String
    var surname: String?
    var identity: String {
        return "\(name) \(surname ?? "")"
    }
    var email: String
    @Published var profilePic: Image?
    let _id: String
    
    public var description: String {return "\(identity) - #\(_id)\n"}

    init(name: String, surname: String?, email: String, photoURL: URL, _id: String) {
        self._id = _id
        self.name = name
        self.surname = surname
        self.email = email
        self.photoURL = photoURL
        DispatchQueue(label: "loadProfilePic", qos: .utility).async {
            do {
                guard let uiimage = try UIImage(data: Data(contentsOf: photoURL)) else { return }
                self.profilePic = Image(uiImage: uiimage)
            } catch {}
        }
    }
}
