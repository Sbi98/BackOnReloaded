//
//  DiscoverDetailedView.swift
//  BackOn
//
//  Created by Emanuele Triuzzi on 04/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI
import MapKit

struct ListView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let mode: RequiredBy
    @State var selectedTask: Task?
    @State var showModal = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                ForEach(shared.arrayFromSet(mode: mode), id: \.ID) { current in
                    Button(action: {
                        self.selectedTask = current
                        self.showModal = true
                    }) {
                        TaskPreview(mode: self.mode, task: current)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color(UIColor(#colorLiteral(red: 0.9450980392, green: 0.8392156863, blue: 0.6705882353, alpha: 1)))))   
                }
            }
            .padding(10)
            .sheet(isPresented: self.$showModal) {DetailedView(requiredBy: self.mode, selectedTask: self.selectedTask!)}
        }
    }
}

//RoundedRectangle(cornerRadius: 15, style: .continuous)
//            .fill(LinearGradient(gradient: Gradient(colors: [Color(UIColor(#colorLiteral(red: 0.9450980392, green: 0.8392156863, blue: 0.6705882353, alpha: 1))), Color(UIColor(#colorLiteral(red: 0.9450980392, green: 0.8392156863, blue: 0.6705882353, alpha: 1)))]), startPoint: .topLeading, endPoint: .bottomTrailing))
//)
