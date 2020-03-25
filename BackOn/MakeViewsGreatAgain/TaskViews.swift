//
//  TaskViews.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 06/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

/*
@State var rating = -1

HStack(alignment: .center, spacing: 10, content: {
    ForEach(0..<5){ i in
        Image(systemName: "star.fill")
            .resizable()
            .frame(width: 35, height: 35)
            .foregroundColor(self.rating < i ? .gray : .yellow)
            .onTapGesture {
                self.rating = i
        }
    }
})
*/

struct TaskPreview: View {
    let mode: RequiredBy
    @ObservedObject var task: Task
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if mode == .RequestViews {
                    Avatar(image:
                    //                    nil
                        (((task.helperID == nil ? nil : self.shared.users[task.helperID!]) ?? noUser).profilePic))
                } else {
                    Avatar(image: self.shared.users[task.neederID]!.profilePic)
                }
                VStack(alignment: .leading) {
                    if mode == .RequestViews {
                        Text(
                        //                        "PROVA"
                            ((task.helperID == nil ? nil : self.shared.users[task.helperID!]!) ?? noUser).identity
                                            )
                            .font(.title) //c'era 26 di grandezza invece di 28
                            .lineLimit(1)
                    } else {
                        Text(self.shared.users[task.neederID]!.identity)
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
        }.padding(12)//.onAppear{self.task.locate()}
    }
}

struct TaskView: View {
    @State var task: Task
    @State var showModal = false
    @State var mapSnap: Image?
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared

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
                            .foregroundColor(Color(.systemOrange))
                            .offset(y: -5)
                            .scaleEffect(0.97)
                        Avatar(image: self.shared.users[task.neederID]!.profilePic)
                            .offset(y: -9.65)
                    }.scaleEffect(1.2)
                    Text(self.shared.users[task.neederID]!.name)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .background(Rectangle().cornerRadius(20).scaleEffect(1.1).foregroundColor(Color(.systemOrange)))
                }
                .offset(y: -160)
                VStack (spacing: 5){
                    Text(self.task.title)
                        .font(.title)
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
                        ForEach(shared.tasksArray(), id: \._id) { currentTask in
    //                        ZStack{
    //                            Color(.black).cornerRadius(10).opacity(0.45).scaleEffect(0.998)
                                TaskView(task: currentTask)
    //                        }
                        }
                    }
                    .padding(20)
                }.offset(x: 0, y: -20)
            }
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
                HStack(spacing: 15) {
                        Image(systemName: "chevron.left")
                            .font(.headline).foregroundColor(Color(.systemOrange))
                        Text("Your tasks")
                            .fontWeight(.bold)
                            .font(.title)
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
