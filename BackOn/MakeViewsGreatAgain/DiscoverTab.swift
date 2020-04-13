//
//  DiscoverDetailedView.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 04/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit

struct FullDiscoverView: View {
    @ObservedObject var discoverTabController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack (alignment: .center) {
            HStack{
            Text("Around you")
                .fontWeight(.bold)
                .font(.title)
                .frame(alignment: .leading)
                .padding(.leading)
                .offset(y: 2)
                Spacer()
            }
            Picker(selection: $discoverTabController.mapMode, label: Text("Select")) {
                Text("List").tag(false)
                Text("Map").tag(true)
            }.pickerStyle(SegmentedPickerStyle()).labelsHidden().padding(.horizontal).offset(y: -5)
            if !shared.canLoadAroundYouMap {
                VStack(alignment: .center){
                Spacer()
                Image(systemName: "mappin.slash")
                    .resizable()
                    .frame(width: 152, height: 205)
                    .imageScale(.large)
                    .font(.largeTitle)
                    .foregroundColor(Color(.systemGray))
                    Text("It seems there's no one to help around you").font(.headline).foregroundColor(Color(.systemGray))
                Spacer()
                }.offset(y: -30)
            } else {
                if discoverTabController.mapMode {
                    discoverTabController.aroundYouMap == nil ? MapView(mode: .AroundYouMap) : discoverTabController.aroundYouMap
                } else {
                    ListView(mode: .DiscoverableViews)
                }
            }
        }
    }
}

struct DiscoverSheetView: View {
    @ObservedObject var discoverTabController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
    
    var body: some View {
        SheetView(isOpen: $discoverTabController.showSheet) {
            if discoverTabController.selectedTask != nil {
                DetailedView(requiredBy: .AroundYouMap, selectedTask: self.discoverTabController.selectedTask!)
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
    @Published var aroundYouMap: MapView?
    @Published var mapMode = true {
        didSet {
            if oldValue == true && self.mapMode == false {
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
