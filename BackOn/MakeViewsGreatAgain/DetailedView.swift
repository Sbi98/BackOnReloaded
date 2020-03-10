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
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    let requiredBy: RequiredBy
    @ObservedObject var selectedTask: Task
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Avatar(image: selectedTask.neederUser.profilePic)
                VStack(alignment: .leading){
                    Text(selectedTask.neederUser.identity)
                        .fontWeight(.bold)
                        .font(Font.custom("SF Pro Text", size: 23))
                        .foregroundColor(.black)
                        .animation(.easeOut(duration: 0))
                    Text(selectedTask.title)
                        .fontWeight(.regular)
                        .font(Font.custom("SF Pro Text", size: 17))
                        .foregroundColor(.black)
                        .animation(.easeOut(duration: 0))
                }.padding(.horizontal)
                Spacer()
                CloseButton(externalColor: #colorLiteral(red: 0.8717954159, green: 0.7912596464, blue: 0.6638498306, alpha: 1), internalColor: #colorLiteral(red: 0.4917932749, green: 0.4582487345, blue: 0.4234881997, alpha: 1))
            }
            .frame(height: 54).padding().background(Color(#colorLiteral(red: 0.9294117647, green: 0.8392156863, blue: 0.6901960784, alpha: 1)))
            if requiredBy != .DiscoverDetailedSheet {
                MapView(mode: requiredBy, selectedTask: selectedTask).offset(y:-10)
            }
            
            if selectedTask.descr != nil {
                Text(selectedTask.descr!)
                    .fontWeight(.regular)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(Font.custom("SF Pro Text", size: 19))
                    .padding(.horizontal, 25).padding(.top, 5).padding(.bottom, 10)
                    .animation(.easeOut(duration: 0))
            }
            
            HStack {
                Spacer()
                OpenInMapsButton(isFilled: requiredBy == RequiredBy.TaskDetailedModal, selectedTask: selectedTask).padding(.horizontal)
                if requiredBy == RequiredBy.DiscoverDetailedModal || requiredBy == RequiredBy.DiscoverDetailedSheet {
                    DoItButton(task: selectedTask).padding(.horizontal)
                } else if requiredBy == RequiredBy.RequestDetailedModal {
                    CantDoItButton().padding(.horizontal) ///CI VA IL BOTTONE DI ANNULLAMENTO DELLA REQUEST
                } else {
                     CantDoItButton().padding(.horizontal)
                }

                Spacer()
            }.padding(.vertical, 5)

            Text("Address")
                .foregroundColor(.secondary)
                .fontWeight(.regular)
                .font(Font.custom("SF Pro Text", size: 17))
                .padding(.top, 10).padding(.horizontal, 25)
                .animation(.easeOut(duration: 0))

            Divider().padding(.horizontal, 25).padding(.top, -5)
            Text("Via Gianluca Rossi 16\n84088 Siano, Provincia di Salerno\nItalia")
                .padding(.horizontal, 25).padding(.top, -5)
                .animation(.easeOut(duration: 0))

            Text("Scheduled Date")
                .foregroundColor(.secondary)
                .fontWeight(.regular)
                .font(Font.custom("SF Pro Text", size: 17))
                .padding(.top, 10).padding(.horizontal, 25)
                .animation(.easeOut(duration: 0))

            Divider().padding(.horizontal, 25).padding(.top, -5)
            Text("\(self.selectedTask.date, formatter: customDateFormat)")
                .padding(.horizontal, 25).padding(.top, -5)
                .animation(.easeOut(duration: 0))
        }
        .onAppear{
            if self.mapController.lastLocation != nil {
                self.selectedTask.requestETA(source: self.mapController.lastLocation!)
            }
        }
        
    }
}
