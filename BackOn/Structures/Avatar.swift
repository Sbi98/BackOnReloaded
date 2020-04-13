//
//  ContentView.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 10/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI

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

