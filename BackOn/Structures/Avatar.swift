//
//  ContentView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 10/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

//struct AvatarOLD: View {
//    let image: String
//    let size: CGFloat
//
//    var body: some View {
//        Image(image)
//            .renderingMode(.original)
//            .resizable()
//            .frame(width: size, height: size)
//            .clipShape(Circle())
//            .overlay(Circle().stroke(Color.white, lineWidth: 2))
//            .shadow(radius: 7)
//    }
//
//}

struct Avatar: View {
    let image: Image
    let size: CGFloat = 50
    
    init(image: Image?) {
        self.image = image == nil ? Image(systemName: "questionmark.circle.fill") : image!
    }

    var body: some View {
        image
            .renderingMode(.original)
            .resizable()
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
//            .shadow(radius: 7)
//            le omre servono per quando non siamo nella mappa, da modificare
    }
}
