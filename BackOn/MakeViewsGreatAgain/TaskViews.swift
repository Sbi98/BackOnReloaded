//
//  TaskViews.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 06/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

struct TaskPreview: View {
    let mode: RequiredBy
    @ObservedObject var task: Task
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if mode == .RequestViews {
                    Avatar(image: task.helperID == nil ? nil : self.shared.users[task.helperID!]?.profilePic)
                } else if mode == .DiscoverableViews {
                    Avatar(image: self.shared.discUsers[task.neederID]?.profilePic)
                } else {
                    Avatar(image: self.shared.users[task.neederID]?.profilePic)
                }
                VStack(alignment: .leading) {
                    if mode == .RequestViews {
                        Text(task.helperID == nil ? "Nobody accepted" : self.shared.users[task.helperID!]?.identity ?? "Helper with bad id")
                            .font(.title) //c'era 26 di grandezza invece di 28
                            .lineLimit(1)
                    } else if mode == .DiscoverableViews {
                        Text(self.shared.discUsers[task.neederID]?.identity ?? "Needer with bad id")
                            .font(.title) //c'era 26 di grandezza invece di 28
                            .lineLimit(1)
                    } else {
                        Text(self.shared.users[task.neederID]?.identity ?? "Needer with bad id")
                            .font(.title) //c'era 26 di grandezza invece di 28
                            .lineLimit(1)
                    }
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.light)
                }.padding(.leading, 5).offset(y: -1)
                Spacer()
            }
            Spacer()
            HStack {
                Text(task.city)
                    .foregroundColor(.secondary)
                    .font(.body)
                Spacer()
                Text("\(task.date, formatter: customDateFormat)")
                    .foregroundColor(.secondary)
                    .font(.body)
            }.offset(y: 1)
        }.padding(12)
    }
}

struct TaskView: View {
    @State var showModal = false
    @ObservedObject var task: Task
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared

    var body: some View {
        Button(action: {self.showModal = true}) {
            ZStack (alignment: .bottom){
                if task.mapSnap == nil {
                    Image("DefaultMap").resizable().blur(radius: 5).frame(width: 320, height: 350).scaledToFill()
                } else {
                    Image(uiImage: task.mapSnap!).resizable().frame(width: 320, height: 350).scaledToFill()
                }
                VStack (spacing: 0){
                    ZStack {
                        Image("cAnnotation")
                            .foregroundColor(Color(.systemOrange))
                            .offset(y: -5)
                            .scaleEffect(0.97)
                        Avatar(image: self.shared.users[task.neederID]?.profilePic)
                            .offset(y: -9.65)
                    }.scaleEffect(1.2)
                    Text(self.shared.users[task.neederID]?.name ?? "Needer with bad id")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .background(Rectangle().cornerRadius(20).scaleEffect(1.1).foregroundColor(Color(.systemOrange)))
                }
                .offset(y: -160)
                VStack (spacing: 5){
                    Text(self.task.title)
                        .fontWeight(.semibold)
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                    Text("\(self.task.date, formatter: customDateFormat)")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .frame(width: 320, alignment: .trailing)
                        .offset(y: 1)
                }
                .frame(width: 320, height: 75)
                .background(Color(UIColor(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1))))
                .cornerRadius(10)
            }
            .frame(width: 320, height: 350)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: self.$showModal) {DetailedView(requiredBy: .TaskViews, selectedTask: self.task)}
    }
}

struct TaskRow: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack {
            if shared.myTasks.isEmpty {
                Spacer()
                Image(systemName: "zzz")
                    .resizable()
                    .frame(width: 140, height: 170)
                    .imageScale(.large)
                    .font(.largeTitle)
                    .foregroundColor(Color(.systemGray))
                Rectangle().hidden().frame(height: 50)
                Text("It seems that you don't have anyone to help").foregroundColor(Color(.systemGray))
                Divider().hidden()
                HStack(spacing: 7) {
                    Spacer()
                    Text("Tap on")
                    Image("DiscoverSymbol").imageScale(.large).font(.title)
                    Text("to find who needs you")
                    Spacer()
                }.font(.body).foregroundColor(Color(.systemGray))
            } else {
                Button(action: {withAnimation{TasksListView.show()}}) {
                    HStack {
                        Text("Your tasks")
                            .fontWeight(.bold)
                            .font(.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundColor(Color(UIColor.systemOrange))
                    }.padding(.horizontal, 20)
                }.buttonStyle(PlainButtonStyle())
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(shared.arrayFromSet(mode: .TaskViews), id: \._id) { currentTask in
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
