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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if mode == .RequestViews {
                    Avatar(image: task.helperUser != nil ? task.helperUser!.profilePic : nil)
                } else {
                    Avatar(image: task.neederUser.profilePic)
                }
                VStack(alignment: .leading) {
                    if mode == .RequestViews {
                        Text(task.helperUser != nil ? task.helperUser!.identity : "Still nobody")
                            .font(Font.custom("SF Pro Text", size: 26))
                            .fontWeight(.regular)
                            .lineLimit(1)
                    } else {
                        Text(task.neederUser.identity)
                            .font(Font.custom("SF Pro Text", size: 26))
                            .fontWeight(.regular)
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
                    .fontWeight(.regular)
                    .font(Font.custom("SF Pro Text", size: 17))
                Spacer()
                Text("\(task.date, formatter: customDateFormat)")
                    .foregroundColor(.secondary)
                    .fontWeight(.regular)
                    .font(Font.custom("SF Pro Text", size: 17))
            }.offset(y: 1)
        }.padding(12).onAppear{self.task.locate()}
    }
}

struct TaskView: View {
    @State var task: Task
    @State var showModal = false
    @State var mapSnap: Image?
    
    var body: some View {
        Button(action: {self.showModal = true}) {
            ZStack (alignment: .bottom){
                if mapSnap == nil {
                    Color.orange.frame(width: 320, height: 350)
                } else {
                    mapSnap
                }
//                MapView(mode: .TaskTab, selectedTask: task)
                VStack (spacing: 0){
                    ZStack {
                        Image("cAnnotation")
                            .foregroundColor(Color(UIColor.systemOrange))
                            .offset(y: -5)
                            .scaleEffect(0.97)
                        Avatar(image: task.neederUser.profilePic)
                            .offset(y: -9.65)
                    }.scaleEffect(1.2)
                    Text(task.neederUser.name)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .font(Font.custom("SF Pro Text", size: 20))
                        .background(Rectangle()
                        .cornerRadius(20)
                        .scaleEffect(1.1)
                        .foregroundColor(Color(UIColor.systemOrange)))
                }
                .offset(y: -160)
                VStack (spacing: 5){
                    Text(self.task.title)
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundColor(Color.white)
                    Text("\(self.task.date, formatter: customDateFormat)")
                        .foregroundColor(Color.secondary)
                        .padding(.horizontal, 10)
                        .frame(width: 320, alignment: .trailing)
                        .offset(y: 1)
                }
                .frame(width: 320, height: 75)
                .background(Color(UIColor(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1))))
                .cornerRadius(10)
                //.shadow(radius: 5) //LA METTIAMO?
            }.onAppear{
                MapController.getSnapshot(location: self.task.position.coordinate, width: 320, height: 350){ snapshot, error in
                    guard error == nil, let snapshot = snapshot else {return}
                    self.mapSnap = Image(uiImage: snapshot.image)
                }
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
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack {
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
                    ForEach(shared.tasksArray(), id: \.ID) { currentTask in
                        ZStack{
                            Color(.black).cornerRadius(10).opacity(0.45).scaleEffect(0.998)
                            TaskView(task: currentTask)
                        }
                    }
                }
                .padding(20)
            }.offset(x: 0, y: -20)
        }
    }
}

struct TasksListView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    @State var selectedTask: Task?
    @State var showModal = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Button(action: {withAnimation{HomeView.show()}}) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.headline).foregroundColor(Color(UIColor.systemBlue))
                        Text("Your tasks")
                            .fontWeight(.bold)
                            .font(.title)
                            .padding(.leading, 5)
                        Spacer()
                    }.padding([.top,.horizontal])
            }.buttonStyle(PlainButtonStyle())
            RefreshableScrollView(height: 70, refreshing: self.$shared.loading) {
                ListView(mode: .TaskViews)
            }
            Spacer()
        }
    }
}
