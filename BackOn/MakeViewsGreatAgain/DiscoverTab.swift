//
//  DiscoverDetailedView.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 04/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI
import MapKit

struct FullDiscoverView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    @ObservedObject var discoverTabController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Picker(selection: $discoverTabController.discoverMode, label: Text("Select")) {
                Text("List").tag(1)
                Text("Map").tag(0)
            }.pickerStyle(SegmentedPickerStyle()).labelsHidden().padding(.horizontal)
            if discoverTabController.discoverMode == 1 {
                VStack (alignment: .center, spacing: 25){
                    ForEach(shared.discoverArray(), id: \.ID) { currentDiscover in
                        Button(action: {
                            self.discoverTabController.selectedTask = currentDiscover
                            self.discoverTabController.showModal = true
                        }) {
                            HStack {
                                UserPreview(user: currentDiscover.neederUser, description: "\(currentDiscover.title)", whiteText: self.darkMode)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.systemBlue))
                            }.padding(.horizontal, 15)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }.padding(.top,20)
            } else {
                MapView(mode: .DiscoverTab).cornerRadius(20)
            }
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: self.$discoverTabController.showModal) {
            DetailedView(requiredBy: .DiscoverDetailedModal, selectedTask: self.discoverTabController.selectedTask!)
        }
    }
}

struct DiscoverSheetView: View {
    @ObservedObject var discoverTabController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
    
    var body: some View {
        SheetView(isOpen: $discoverTabController.showSheet) {
            if discoverTabController.selectedTask != nil {
                DetailedView(requiredBy: .DiscoverDetailedSheet, selectedTask: self.discoverTabController.selectedTask!)
                    .transition(.move(edge: .bottom))
            } else {
                EmptyView()
            }
        }
    }
}


class DiscoverTabController: ObservableObject {
    @Published var showSheet = false
    @Published var showModal = false
    @Published var selectedTask: Task?
    @Published var baseMKMap: MKMapView?
    @Published var discoverMode = 0 {
        didSet {
            if oldValue == 0 && self.discoverMode == 1 {
                self.closeSheet()
            }
        }
    }
    
    func showSheet(task: Task) {
        self.selectedTask = task
        showSheet = true
    }
    
    func closeSheet() {
        showSheet = false
        selectedTask = nil
        baseMKMap?.deselectAnnotation(baseMKMap?.selectedAnnotations.first, animated: true)
    }
}
