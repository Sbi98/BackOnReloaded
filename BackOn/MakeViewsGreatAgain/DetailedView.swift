//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit

struct DetailedView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let requiredBy: RequiredBy
    @ObservedObject var selectedTask: Task
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Avatar(image:
//                    nil
                    (((selectedTask.helperID == nil ? nil : self.shared.users[selectedTask.helperID!]) ?? noUser).profilePic))
                VStack(alignment: .leading){
                    Text(
//                        "PROVA"
                        ((selectedTask.helperID == nil ? nil : self.shared.users[selectedTask.helperID!]) ?? noUser).identity
                    )
                        .fontWeight(.medium)
                        .font(.title)
                        .animation(.easeOut(duration: 0))
                    Text(selectedTask.title)
                        .font(.body)
                        .animation(.easeOut(duration: 0))
                }.padding(.horizontal)
                Spacer()
                CloseButton(externalColor: #colorLiteral(red: 0.8717954159, green: 0.7912596464, blue: 0.6638498306, alpha: 1), internalColor: #colorLiteral(red: 0.4917932749, green: 0.4582487345, blue: 0.4234881997, alpha: 1))
            }
            .frame(height: 54)
            .padding()
            .background(Color(#colorLiteral(red: 0.9294117647, green: 0.8392156863, blue: 0.6901960784, alpha: 1)))
            if requiredBy != .AroundYouMap {
                MapView(mode: requiredBy, selectedTask: selectedTask).offset(y: -10)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                if selectedTask.descr != nil {
                    Text(selectedTask.descr!)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 19))
                        .animation(.easeOut(duration: 0))
                }
                
                HStack {
                    Spacer()
                    if requiredBy == .DiscoverableViews || requiredBy == .AroundYouMap {
                        DirectionsButton(selectedTask: selectedTask)
                        DoItButton(task: selectedTask)
                    } else if requiredBy == .RequestViews {
                        DontNeedAnymoreButton(requestid: selectedTask._id)
                    } else {
                        DirectionsButton(selectedTask: selectedTask)
                        CantDoItButton(taskid: selectedTask._id)
                    }
                    Spacer()
                }.padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 5) { //Address section
                    Text("Address")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .animation(.easeOut(duration: 0))
                    Divider()
                    Text(selectedTask.address)
                        .animation(.easeOut(duration: 0))
                }
                
                VStack(alignment: .leading, spacing: 5) { //Scheduled date section
                    Text("Scheduled Date")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .animation(.easeOut(duration: 0))
                    Divider()
                    Text("\(self.selectedTask.date, formatter: customDateFormat)")
                        .animation(.easeOut(duration: 0))
                }
            }.padding(.horizontal, 20)
        }
    }
}
