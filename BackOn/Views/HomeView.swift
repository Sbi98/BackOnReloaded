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
    @State var isLoading: Bool = true
    
    var body: some View {
        RefreshableScrollView(height: 70, refreshing: self.$shared.loading) {
            VStack (alignment: .leading, spacing: 10) {
                HStack (alignment: .center, spacing: 10) {
                    Text("Hi \(CoreDataController.loggedUser!.name)!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    ProfileButton()
                    AddNeedButton()
                }.padding(.horizontal).padding(.top, 10)
                TaskRow()
                RequestRow()
                Button(action: {
                    print("Logout!")
                    GIDSignIn.sharedInstance()?.disconnect()
                }) {
                    Text("Logout")
                        .bold()
                        .foregroundColor(.black)
                }
                GenericButton(isFilled: true, color: .systemOrange, topText: "Save in C.D."){
                    print("salvo in coredata")
                    CoreDataController.addTasks(tasks: self.shared.tasksArray())
                }
                Divider().hidden()
                GenericButton(isFilled: true, color: .systemOrange, topText: "Load from C.D."){
                    print("leggo da coredata")
                    print(CoreDataController.getCachedTasks())
                }
            }
        }
    }
    
}
