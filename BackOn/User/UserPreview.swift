//
//  UserPreview.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

struct UserPreview: View {
    var user: UserInfo
    var descr: String
    var whiteText: Bool
    var textColor: Color{
        get {
            return whiteText ? Color.white : Color.black
        }
    }
    
    init(user: UserInfo, description descr: String, whiteText: Bool) {
        self.user = user
        self.descr = descr
        self.whiteText = whiteText
    }
    
    init(user: UserInfo, whiteText: Bool) {
        self.user = user
        descr = ""
        self.whiteText = whiteText

    }
    
    var body: some View {
        HStack {
//            Avatar(image: "\(user.photo)", size: 60)
            Avatar(image: user.profilePic)
            VStack (alignment: .leading){
                Text(user.identity)
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundColor(textColor)
                    .offset(x: 0, y: -3)
                    .lineLimit(1)
                if descr != "" {
                    Text(descr)
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(textColor)
                        .offset(x: 0, y: 1)
                        .lineLimit(2)
                }
            }.padding(.leading, 5)
            Spacer()
        }
    }
}

