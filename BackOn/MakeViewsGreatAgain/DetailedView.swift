//
//  Certificates.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 11/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI
import MapKit

struct DetailedView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let requiredBy: RequiredBy
    @ObservedObject var selectedTask: Task
    @State var showBusyDetail = false
    
    var body: some View {
        let isExpired = selectedTask.isExpired()
        return VStack(alignment: .leading, spacing: 0){
            HStack (spacing: 0) {
                if requiredBy == .RequestViews {
                    Avatar(selectedTask.helperID == nil ? nil : shared.users[selectedTask.helperID!])
                } else if requiredBy == .DiscoverableViews || requiredBy == .AroundYouMap {
                    Avatar(shared.discUsers[selectedTask.neederID])
                } else {
                    Avatar(shared.users[selectedTask.neederID])
                }
                VStack(alignment: .leading) {
                    if requiredBy == .RequestViews {
                        Text(selectedTask.helperID == nil ? "Nobody accepted" : self.shared.users[selectedTask.helperID!]?.identity ?? "Helper with bad id")
                            .fontWeight(.medium)
                    } else if requiredBy == .DiscoverableViews  || requiredBy == .AroundYouMap {
                        Text(self.shared.discUsers[selectedTask.neederID]?.identity ?? "Needer with bad id")
                            .fontWeight(.medium)
                    } else {
                        Text(self.shared.users[selectedTask.neederID]?.identity ?? "Needer with bad id")
                            .fontWeight(.medium)
                    }
                    Text(selectedTask.title).font(.body)
                }.font(.title).tint(.white).padding(.horizontal)
                Spacer()
                CloseButton()
            }
            .frame(height: 55)
            .padding()
            .backgroundIf(isExpired, .expiredTask, .detailedTaskHeaderBG)
            if requiredBy != .AroundYouMap {
                MapView(mode: requiredBy, selectedTask: selectedTask)
            }
            VStack(alignment: .leading, spacing: 20) {
                Divider().hidden()
                if selectedTask.descr != nil {
                    Text(selectedTask.descr!)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 19))
                }
                HStack {
                    if requiredBy == .DiscoverableViews || requiredBy == .AroundYouMap {
                        DirectionsButton(selectedTask: selectedTask)
                        Spacer()
                        DoItButton(task: selectedTask)
                    } else if requiredBy == .RequestViews {
                        if isExpired {
                            if selectedTask.helperID == nil {
                                Spacer()
                                AskAgainButton(request: selectedTask)
                                Spacer()
                            } else {
                                ThankButton(helperToReport: true, task: selectedTask)
                                Spacer()
                                ReportButton(helperToReport: true, task: selectedTask)
                            }
                        } else {
                            Spacer()
                            DontNeedAnymoreButton(request: selectedTask)
                            Spacer()
                        }
                    } else {
                        if isExpired {
                            ThankButton(helperToReport: false, task: selectedTask)
                            Spacer()
                            ReportButton(helperToReport: false, task: selectedTask)
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
                    Divider()
                    Text(selectedTask.address)
                }
                
                VStack(alignment: .leading, spacing: 5) { //Scheduled date section
                    Text("Scheduled Date")
                        .foregroundColor(.secondary)
                        .font(.body)
                    Divider()
                    HStack {
                        if showBusyDetail {
                            Text("You seem busy, check the calendar").tint(.yellow).onTapGesture{self.showBusyDetail.toggle()}
                        } else {
                            Text("\(self.selectedTask.date, formatter: customDateFormat)")
                        }
                        if (requiredBy == .DiscoverableViews || requiredBy == .AroundYouMap) && CalendarController.isBusy(when: selectedTask.date) {
                            if !showBusyDetail {
                                Image(systemName: "exclamationmark.triangle").tint(.yellow).onTapGesture{self.showBusyDetail.toggle()}
                            }
                        }
                        Spacer()
                    }
                }
                if !isExpired && (requiredBy == RequiredBy.TaskViews || requiredBy == RequiredBy.RequestViews && selectedTask.helperID != nil){
                    HStack {
                        Spacer()
                        CallButton(phoneNumber: (requiredBy == RequiredBy.TaskViews ?  shared.users[selectedTask.neederID]?.phoneNumber: shared.users[selectedTask.helperID!]?.phoneNumber), date: selectedTask.date)
                        Spacer()
                    }
                }
                
            }.padding(.horizontal, 20)
        }.animation(.easeOut(duration: 0))
    }
}

struct DetailedView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedView(requiredBy: .RequestViews, selectedTask: Task(neederID: "mio", title: "Preview", date: Date()+20000, latitude: 40.1, longitude: 14.5, _id: "ciao"))
    }
}
