//
//  TaskViews.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 06/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

struct TaskView: View {
    @State var task: Task
    @State var showModal = false
    
    var body: some View {
        Button(action: {self.showModal = true}) {
            ZStack (alignment: .bottom){
                MapView(mode: .TaskTab, selectedTask: task)
                VStack (spacing: 2){
                    ZStack {
                        Image("cAnnotation")
                            .foregroundColor(Color(UIColor.systemOrange))
                            .offset(y: -5)
                            .scaleEffect(0.97)
                        Avatar(image: task.neederUser.profilePic)
                            .offset(y: -9.65)
                    }.scaleEffect(1.2)
                    Text(task.neederUser.name)
                        .foregroundColor(Color.white)
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
                    //Text(self.commitment.city).onAppear{self.commitment.locate()}
                    Text("\(self.task.date, formatter: customDateFormat)")
                        .foregroundColor(Color.secondary)
                        .padding(.horizontal, 10)
                        .frame(width: 320, alignment: .trailing)
                        .offset(y:10)
                }
                .frame(width: 320, height: 90)
                .background(Color(UIColor(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1))))
                .cornerRadius(10)
                    .shadow(radius: 5) ///LA METTIAMO?
            }
            .frame(width: 320, height: 350)
            .cornerRadius(10)
            .shadow(radius: 5)
        }.buttonStyle(PlainButtonStyle())
            .sheet(isPresented: self.$showModal, content: {
                DetailedView(requiredBy: .TaskDetailedModal, selectedTask: self.task)
            })
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
            Button(action: {withAnimation{
                HomeView.show()}}) {
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
                ListView(mode: RequiredBy.TaskTab)
            }
            Spacer()
        }
        .padding(.top, 40)
        .edgesIgnoringSafeArea(.all)
    }
}
