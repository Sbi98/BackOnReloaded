//
//  TaskViews.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 06/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI

struct TaskPreview: View {
    let mode: RequiredBy
    @ObservedObject var task: Task
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        let isExpired = task.isExpired()
        let hasHelper = task.helperID != nil
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                if mode == .RequestViews {
                    if !hasHelper {
                        if isExpired {
                            Avatar(nil)
                        } else {
                            Avatar(nil).overlay(Circle().stroke(Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)), lineWidth: 1))
                        }
                    } else {
                        Avatar(shared.users[task.helperID!])
                    }
                } else if mode == .DiscoverableViews {
                    Avatar(shared.discUsers[task.neederID])
                } else {
                    Avatar(shared.users[task.neederID])
                }
                VStack(alignment: .leading) {
                    if mode == .RequestViews {
                        Text(!hasHelper ? "Nobody accepted" : shared.users[task.helperID!]?.identity ?? "Helper not found")
                    } else if mode == .DiscoverableViews {
                        Text(shared.discUsers[task.neederID]?.identity ?? "Needer not found")
                    } else {
                        Text(shared.users[task.neederID]?.identity ?? "Needer not found")
                    }
                    Text(task.title).font(.subheadline).fontWeight(.light)
                }
                .font(.title) //c'era 26 di grandezza invece di 28
                .lineLimit(1)
                .tintIf(mode == .RequestViews && !hasHelper && !isExpired, .task, .white) //usa l'arancione del BG dei task per il testo delle request non accettate
                .padding(.leading, 5)
                .offset(y: -1)
                Spacer()
            }
            Spacer()
            HStack {
                Text(task.city)
                Spacer()
                Text("\(task.date, formatter: customDateFormat)")
            }.font(.body).tint(.secondary).offset(y: 1)
        }
        .padding(12)
        .backgroundIf(isExpired, .expiredTask, mode == .RequestViews && !hasHelper ? .white : .task)
        .overlayIf(.constant(mode == .RequestViews && !hasHelper && !isExpired), toOverlay: RoundedRectangle(cornerRadius: 10).stroke(Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)), lineWidth: 3))
        .loadingOverlay(isPresented: $task.waitingForServerResponse)
        .cornerRadius(10)
    }
}

struct TaskView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: Task
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    @State var showModal = false
    
    var body: some View {
        Button(action: {self.showModal = true}) {
            ZStack (alignment: .bottom){
                if task.lightMapSnap != nil && task.darkMapSnap != nil {
                    if colorScheme == .dark {Image(uiImage: task.darkMapSnap!).resizable().frame(width: 320, height: 350).scaledToFill()}
                    else {Image(uiImage: task.lightMapSnap!).resizable().frame(width: 320, height: 350).scaledToFill()}
                } else {
                    Image("DefaultMap").resizable().blur(radius: 5).frame(width: 320, height: 350).scaledToFill()
                }
                VStack (spacing: 0){
                    ZStack {
                        Image("cAnnotation").orange().offset(y: -5).scaleEffect(0.97)
                        Avatar(shared.users[task.neederID]).offset(y: -9.65)
                    }.scaleEffect(1.2)
                    Text(shared.users[task.neederID]?.name ?? "Needer not found")
                        .fontWeight(.semibold)
                        .orange()
                        .background(Rectangle().cornerRadius(13).tint(.white).shadow(radius: 5).scaleEffect(1.4))
                        .offset(y: 3)
                }
                .offset(y: -160)
                VStack (spacing: 5){
                    Text(task.title)
                        .fontWeight(.semibold)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text("\(task.date, formatter: customDateFormat)")
                        .tint(.taskGray)
                        .padding(.horizontal, 10)
                        .frame(width: 320, alignment: .trailing)
                        .offset(y: 1)
                }
                .frame(width: 320, height: 75)
                .backgroundIf(task.isExpired(), .expiredTask, .task)
                .cornerRadius(10)
            }
            .frame(width: 320, height: 350)
            .loadingOverlay(isPresented: $task.waitingForServerResponse)
            .cornerRadius(10)
            .shadow(color: Color(.systemGray3), radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: self.$showModal) {DetailedView(requiredBy: .TaskViews, selectedTask: self.task)}
    }
}

struct TaskRow: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack {
            if shared.myTasks.isEmpty && shared.myExpiredTasks.isEmpty {
                SizedDivider(height: 50)
                Image(systemName: "zzz")
                    .resizable()
                    .frame(width: 140, height: 170)
                    .imageScale(.large)
                    .font(.largeTitle)
                    .tint(.gray)
                SizedDivider(height: 40)
                Text("It seems that you don't have anyone to help").tint(.gray)
                Divider().hidden()
                HStack(spacing: 7) {
                    Spacer()
                    Text("Tap on")
                    Image("DiscoverSymbol").imageScale(.large).font(.title)
                    Text("to find who needs you")
                    Spacer()
                }
                .font(.body)
                .tint(.gray)
                SizedDivider(height: 83)
            } else {
                Button(action: {withAnimation{TasksListView.show()}}) {
                    HStack {
                        Text("Your tasks")
                            .fontWeight(.bold)
                            .font(.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .orange()
                    }.padding(.horizontal, 20)
                }.buttonStyle(PlainButtonStyle())
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(shared.arrayFromSet(mode: .TaskViews), id: \._id) { currentTask in
                            TaskView(task: currentTask)
                        }
                        ForEach(shared.arrayFromSet(mode: .TaskViews, expiredSet: true), id: \._id) { currentTask in
                            TaskView(task: currentTask)
                        }
                    }
                    .padding(20)
                }.offset(x: 0, y: -20)
            }
        }
    }
}

struct TasksListView: View {    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Button(action: {withAnimation{HomeView.show()}}) {
                HStack(spacing: 15) {
                    Image(systemName: "chevron.left")
                        .font(.headline).foregroundColor(Color(.systemOrange))
                    Text("Your tasks")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                }.padding([.top,.horizontal])
            }.buttonStyle(PlainButtonStyle())
            ListView(mode: .TaskViews)
            Spacer()
        }
    }
}
