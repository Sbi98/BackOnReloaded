//
//  UserInfo.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

class User: ObservableObject, CustomStringConvertible {
    let _id: String
    let email: String
    var name: String
    var surname: String?
    var identity: String { return "\(name) \(surname ?? "")" }
    var photoURL: URL
    var photo: UIImage?
    @Published var profilePic: Image?
    
    
    public var description: String {return "\(identity) - #\(_id)\n"}

    init(name: String, surname: String?, email: String, photoURL: URL, _id: String, photo: UIImage? = nil) {
        self._id = _id
        self.name = name
        self.surname = surname
        self.email = email
        self.photoURL = photoURL
        if let photo = photo {
            self.photo = photo
            profilePic = Image(uiImage: photo)
        } else {
            DispatchQueue(label: "loadProfilePic", qos: .utility).async {
                do {
                    guard let uiimage = try UIImage(data: Data(contentsOf: photoURL)) else { return }
                    self.profilePic = Image(uiImage: uiimage)
                } catch {}
            }
        }
    }
}
