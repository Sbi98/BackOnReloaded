//
//  UserPreview.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//
/*
import SwiftUI

struct UserPreview: View {
    var user: User
    var descr: String
    var whiteText: Bool
    var textColor: Color{
        get {
            return whiteText ? Color.white : Color.black
        }
    }
    
    init(user: User, description descr: String, whiteText: Bool) {
        self.user = user
        self.descr = descr
        self.whiteText = whiteText
    }
    
    init(user: User, whiteText: Bool) {
        self.user = user
        descr = ""
        self.whiteText = whiteText

    }
    
    var body: some View {
        HStack {
            Avatar(image: user.profilePic)
            VStack (alignment: .leading){
                Text(user.identity)
                    .font(.title)
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
*/
