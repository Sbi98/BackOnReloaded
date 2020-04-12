//
//  ContentView.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 10/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

extension Image {
    func avatar(size: CGFloat = 50) -> some View {
        return self
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(Color(.systemOrange))
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
    }
}

struct Avatar: View {
    let image: Image
    let size: CGFloat
    
    init(image: Image?, size: CGFloat = 50) {//Image(systemName: "questionmark.circle.fill")
        self.image = image == nil ? Image("NobodyIcon") : image!.renderingMode(.original)
        self.size = size
    }

    var body: some View {
        image
            .resizable()
            .orange()
            .scaledToFit()
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
//            .shadow(radius: 7)
//            le omre servono per quando non siamo nella mappa, da modificare
    }
}
