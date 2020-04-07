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
        VStack(alignment: .leading, spacing: 0){
            HStack {
                if requiredBy == .RequestViews {
                    Avatar(image: selectedTask.helperID == nil ? nil : self.shared.users[selectedTask.helperID!]?.profilePic)
                } else if requiredBy == .DiscoverableViews || requiredBy == .AroundYouMap {
                    Avatar(image: self.shared.discUsers[selectedTask.neederID]?.profilePic)
                } else {
                    Avatar(image: self.shared.users[selectedTask.neederID]?.profilePic)
                }
                VStack(alignment: .leading){
                    if requiredBy == .RequestViews {
                        Text(selectedTask.helperID == nil ? "Nobody accepted" : self.shared.users[selectedTask.helperID!]?.identity ?? "Helper with bad id")
                            .fontWeight(.medium)
                            .font(.title)
                            .animation(.easeOut(duration: 0))
                    } else if requiredBy == .DiscoverableViews  || requiredBy == .AroundYouMap {
                        Text(self.shared.discUsers[selectedTask.neederID]?.identity ?? "Needer with bad id")
                            .fontWeight(.medium)
                            .font(.title)
                            .animation(.easeOut(duration: 0))
                    } else {
                        Text(self.shared.users[selectedTask.neederID]?.identity ?? "Needer with bad id")
                            .fontWeight(.medium)
                            .font(.title)
                            .animation(.easeOut(duration: 0))
                    }
                    Text(selectedTask.title)
                        .font(.body)
                        .animation(.easeOut(duration: 0))
                }.padding(.horizontal)
                Spacer()
                CloseButton()
            }
            .frame(height: 54)
            .padding()
            .background(selectedTask.isExpired() ? Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)) : Color(#colorLiteral(red: 0.9294117647, green: 0.8392156863, blue: 0.6901960784, alpha: 1)))
            if requiredBy != .AroundYouMap {
                MapView(mode: requiredBy, selectedTask: selectedTask)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Divider().hidden()
                if selectedTask.descr != nil {
                    Text(selectedTask.descr!)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 19))
                        .animation(.easeOut(duration: 0))
                }
                
                HStack {
                    if requiredBy == .DiscoverableViews || requiredBy == .AroundYouMap {
                        DirectionsButton(selectedTask: selectedTask)
                        Spacer()
                        DoItButton(task: selectedTask)
                    } else if requiredBy == .RequestViews {
                        if selectedTask.isExpired() {
                            if selectedTask.helperID == nil {
                                Spacer()
                                AskAgainButton(request: selectedTask)
                                Spacer()
                            }else{
                                ThankButton(toReport: "helper", task: selectedTask)
                                Spacer()
                                ReportButton(toReport: "helper", task: selectedTask)
                            }
                        } else {
                            Spacer()
                            DontNeedAnymoreButton(request: selectedTask)
                            Spacer()
                        }
                    } else {
                        if selectedTask.isExpired(){
                            ThankButton(toReport: "needer", task: selectedTask)
                            Spacer()
                            ReportButton(toReport: "needer", task: selectedTask)
                        } else {
                            DirectionsButton(selectedTask: selectedTask)
                            Spacer()
                            CantDoItButton(task: selectedTask)
                        }
                    }
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
