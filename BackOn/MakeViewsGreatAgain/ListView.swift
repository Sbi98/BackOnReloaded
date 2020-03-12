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
    
    @ObservedObject var discoverTabController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
    
    let mode: RequiredBy
    
    var body: some View {
        ScrollView(Axis.Set.vertical, showsIndicators: true){
            VStack (alignment: .leading){
                
                if(mode == RequiredBy.DiscoverTab || mode == RequiredBy.TaskTab) {
                    
                    if(mode == RequiredBy.DiscoverTab){
                        Text("Around you")
                            .fontWeight(.bold)
                            .font(.title)
                            .padding(.leading, 15)
                    }
                    
                    ForEach(mode == RequiredBy.DiscoverTab ? shared.discoverablesArray() : shared.tasksArray(), id: \.ID) { current in
                        Button(action: {
                            self.discoverTabController.selectedTask = current
                            self.discoverTabController.showModal = true
                        }) {
                            VStack(alignment: .leading){
                                HStack{
                                    Avatar(image: current.neederUser.profilePic)
                                    VStack (alignment: .leading){
                                        Text(current.neederUser.identity)
                                            .font(Font.custom("SF Pro Text", size: 26))
                                            .fontWeight(.regular)
                                            .offset(x: 0, y: -3)
                                            .lineLimit(1)
                                        
                                        Text(current.title)
                                            .font(.subheadline)
                                            .fontWeight(.light)
                                            .offset(x: 0, y: 1)
                                            .lineLimit(2)
                                        
                                    }.padding(.leading, 5)
                                    Spacer()
                                }
                                HStack {
                                Text("\(current.city)")
                                    .foregroundColor(.secondary)
                                    .fontWeight(.regular)
                                    .font(Font.custom("SF Pro Text", size: 17))
                                Spacer()
                                Text("\(current.date, formatter: customDateFormat)")
                                    .foregroundColor(.secondary)
                                    .fontWeight(.regular)
                                    .font(Font.custom("SF Pro Text", size: 17))
                                }
                            }.padding(15)
                        }.buttonStyle(PlainButtonStyle())
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [Color(UIColor(#colorLiteral(red: 0.9450980392, green: 0.8392156863, blue: 0.6705882353, alpha: 1))), Color(UIColor(#colorLiteral(red: 0.9450980392, green: 0.8392156863, blue: 0.6705882353, alpha: 1)))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        )
                    }
                }//FINE IF DISCOVER o TASK
                
                if(mode == RequiredBy.RequestDetailedModal) {
                    ForEach(shared.requestsArray(), id: \.ID) { current in
                        Button(action: {
                            self.discoverTabController.selectedTask = current
                            self.discoverTabController.showModal = true
                        }) {
                            VStack(alignment: .leading){
                                HStack{
                                    Avatar(image: current.helperUser != nil ? current.helperUser!.profilePic : nil)
                                    VStack (alignment: .leading){
                                        Text(current.helperUser != nil ? current.helperUser!.identity : "Still nobody")
                                            .font(Font.custom("SF Pro Text", size: 26))
                                            .fontWeight(.regular)
                                            .offset(x: 0, y: -3)
                                            .lineLimit(1)
                                        
                                        Text(current.title)
                                            .font(.subheadline)
                                            .fontWeight(.light)
                                            .offset(x: 0, y: 1)
                                            .lineLimit(2)
                                        
                                    }.padding(.leading, 5)
                                    Spacer()
                                }
                                HStack{
                                    Text(current.address)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.regular)
                                        .font(Font.custom("SF Pro Text", size: 17))
                                    Spacer()
                                    Text("\(current.date, formatter: customDateFormat)")
                                        .foregroundColor(.secondary)
                                        .fontWeight(.regular)
                                        .font(Font.custom("SF Pro Text", size: 17))
                                }
                            }.padding(15)
                        }.buttonStyle(PlainButtonStyle())
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [Color(UIColor(#colorLiteral(red: 0.9450980392, green: 0.8392156863, blue: 0.6705882353, alpha: 1))), Color(UIColor(#colorLiteral(red: 0.9450980392, green: 0.8392156863, blue: 0.6705882353, alpha: 1)))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        )
                    }
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)
            .padding(.bottom, 65)
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: self.$discoverTabController.showModal) {
                DetailedView(requiredBy: .DiscoverDetailedModal, selectedTask: self.discoverTabController.selectedTask!)
            }
        }
    } //Body
}
