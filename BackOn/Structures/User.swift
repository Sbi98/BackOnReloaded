//
//  UserInfo.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 11/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI

class User: ObservableObject, CustomStringConvertible {
    let _id: String
    let email: String
    var name: String
    var surname: String?
    var identity: String { return "\(name) \(surname ?? "")" }
    var photoURL: URL?
    @Published var photo: UIImage?
    
    public var description: String {return "\(identity) - #\(_id)\n"}

    init(_id: String, name: String, surname: String?, email: String, photoURL: URL?, photo: UIImage? = nil) {
        self._id = _id
        self.name = name
        self.surname = surname
        self.email = email
        self.photoURL = photoURL
        if photo != nil {
            self.photo = photo!
        } else {
            DispatchQueue(label: "loadProfilePic", qos: .utility).async {
                do {
                    guard photoURL != nil, let uiimage = try UIImage(data: Data(contentsOf: photoURL!)) else { return }
                    DispatchQueue.main.async { self.photo = uiimage }
                } catch {}
            }
        }
    }
}

struct Avatar: View {
    @ObservedObject var user: User
    let size: CGFloat
    
    init(_ user: User?, size: CGFloat = 50) {
        self.user = user ?? userNotFound
        self.size = size
    }

    var body: some View {
        Image(uiImage: user.photo).avatar(size: size)
    }
}

let userNotFound = User(_id: "", name: "User not found", surname: nil, email: "", photoURL: nil)

/*
static func == (lhs: User, rhs: User) -> Bool {
    return
        lhs._id == rhs._id &&
        lhs.photoURL == rhs.photoURL &&
        lhs.identity == rhs.identity
}
*/
