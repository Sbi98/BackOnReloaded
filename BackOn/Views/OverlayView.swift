//
//  OverlayView.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 19/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct myOverlay: View {
    @Binding var isPresented: Bool
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let toOverlay: AnyView
    
    var body: some View {
        VStack {
            if self.isPresented{
                if shared.viewToShow == "FullDiscoverView"{
                    toOverlay
                } else {
                    Color
                        .black
                        .opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation() {
                                self.isPresented = false
                            }
                    }
                    .overlay(
                        toOverlay,
                        alignment: .bottom
                    )
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .animation(.easeInOut)
                }
            } else {
                EmptyView()
                    .animation(.easeInOut)
            }
        }
    }
}
