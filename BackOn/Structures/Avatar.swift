//
//  ContentView.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 10/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

struct Avatar: View {
    let image: Image
    let size: CGFloat
    
    init(image: Image?, size: CGFloat = 50) {
        self.image = image == nil ? Image(systemName: "questionmark.circle.fill") : image!
        self.size = size
    }

    var body: some View {
        image
            .renderingMode(.original)
            .resizable()
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
//            .shadow(radius: 7)
//            le omre servono per quando non siamo nella mappa, da modificare
    }
}
