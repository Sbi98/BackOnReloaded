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

struct SearchBar : UIViewRepresentable {
    @Binding var text : String
    
    class Coordinator : NSObject, UISearchBarDelegate {
        @Binding var text : String
        
        init(_ text : Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator($text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

struct searchLocation: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var selection: String
    @State var userLocationAddress: String = "Processing your current location..."
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    
    class AddressCompleterHandler: NSObject, MKLocalSearchCompleterDelegate, ObservableObject {
        @Published var completer = MKLocalSearchCompleter()
        override init() {
            super.init()
            completer.delegate = self
        }
    }
    @ObservedObject var addressCompleter = AddressCompleterHandler()
    
    var body: some View {
        Form {
            Section (header: SearchBar(text: $addressCompleter.completer.queryFragment)) {
                Text(userLocationAddress).onTapGesture {
                    self.selection = self.userLocationAddress
                    self.presentationMode.wrappedValue.dismiss()
                }
                ForEach(addressCompleter.completer.results, id: \.hashValue) { currentItem in
                    Text("\(currentItem.title) (\(currentItem.subtitle))").onTapGesture {
                        self.selection = "\(currentItem.title) (\(currentItem.subtitle))"
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }.onAppear() {
            self.mapController.coordinatesToAddress() { result in
                self.userLocationAddress = result
            }
        }
    }
}
