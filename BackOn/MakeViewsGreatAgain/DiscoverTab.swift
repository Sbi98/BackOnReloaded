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
        VStack (alignment: .leading) {
            Picker(selection: $discoverTabController.discoverMode, label: Text("Select")) {
                Text("List").tag(1)
                Text("Map").tag(0)
            }.pickerStyle(SegmentedPickerStyle()).labelsHidden().padding()
            if discoverTabController.discoverMode == 1 {
                ListView(mode: .DiscoverableViews).cornerRadius(20)
            } else {
                MapView(mode: .AroundYouMap).cornerRadius(20)
            }
        }
    }
}

struct DiscoverSheetView: View {
    @ObservedObject var discoverTabController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
    
    var body: some View {
        SheetView(isOpen: $discoverTabController.showSheet) {
            if discoverTabController.selectedTask != nil {
                DetailedView(requiredBy: .DiscoverableViews, selectedTask: self.discoverTabController.selectedTask!)
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
    
    func showModal(task: Task) {
        self.selectedTask = task
        showModal = true
    }
    
    func closeModal() {
        showModal = false
        selectedTask = nil
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
