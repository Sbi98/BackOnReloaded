//
//  HomeView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import GoogleSignIn

struct HomeView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    @State var isLoading: Bool = true
    @State var showAddNeedModal = false
    @State var showProfileModal = false
    
    var body: some View {
        RefreshableScrollView(height: 70, refreshing: self.$shared.loading) {
            VStack {
                HStack {
                    Text("Hi \(CoreDataController.loggedUser!.name)!")
                        .font(.largeTitle)
                        .bold()
                        .fontWeight(.heavy)
                    Spacer()
                    ProfileButton(showModal: self.$showProfileModal).offset(x: 10, y:2)
                    AddNeedButton(showModal: self.$showAddNeedModal).offset(y: 3)
                }.padding(.horizontal).padding(.top, 10)
                TaskRow().offset(y: -20)
                RequestRow().offset(y: -35)
                Button(action: {
                    print("Logout!")
                    GIDSignIn.sharedInstance()?.disconnect()
                }) {
                    Text("Logout")
                        .bold()
                        .foregroundColor(.black)
                }
                GenericButton(isFilled: true, color: .systemOrange, topText: Text("Save in C.D.")){
                    print("salvo in coredata")
                    CoreDataController.addTasks(tasks: self.shared.tasksArray())
                }
                Divider().hidden()
                GenericButton(isFilled: true, color: .systemOrange, topText: Text("Load from C.D.")){
                    print("leggo da coredata")
                    print(CoreDataController.getCachedTasks())
                }
            }
        }
        .padding(.top, 40)
            //        .background(Color.primary.colorInvert())
            .edgesIgnoringSafeArea(.vertical)
            .sheet(isPresented: self.$showAddNeedModal){
                AddNeedView()
        }
        .sheet(isPresented: self.$showProfileModal){
            AddNeedView()
        }
    }
    
}
