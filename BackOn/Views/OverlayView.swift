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
    let toOverlay: AnyView
 
    var body: some View {
        VStack {
            if self.isPresented {
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
            } else {
                EmptyView()
                    .animation(.easeInOut)
            }
        }
    }
}

struct searchLocation: View {
    @State var toSearch: String = ""
    @State var matchingItems: [MKLocalSearchCompletion] = []
    
    class LocationController: NSObject, MKLocalSearchCompleterDelegate, ObservableObject {
        @Published var searchResults = [MKLocalSearchCompletion]()
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            searchResults = completer.results
            print(completer.results, "\n--------------------------\n")
        }
    }
    @ObservedObject var locationController = LocationController()
    var completer = MKLocalSearchCompleter()
    
    init() {
        completer.delegate = locationController
        completer.queryFragment = toSearch
        completer.resultTypes = .address
    }
    
    func onEditingChanged(textChanged: Bool) {
        completer.queryFragment = toSearch
    }
    
    var body: some View {
        VStack {
            TextField("Write your location", text: $toSearch, onEditingChanged: onEditingChanged(textChanged:), onCommit: {})
            VStack {
                ForEach(locationController.searchResults, id: \.title) { currentItem in
                    Text("\(currentItem.title) (\(currentItem.subtitle))")
                }
            }
        }
    }
}
