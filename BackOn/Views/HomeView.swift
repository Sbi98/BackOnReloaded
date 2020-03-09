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
    
    var body: some View {
        RefreshableScrollView(height: 70, refreshing: self.$shared.loading) {
            VStack (alignment: .leading, spacing: 0){
                HStack{
                    Text("Hi \(shared.loggedUser!.name)!")
                        .font(.largeTitle)
                        .bold()
                        .fontWeight(.heavy)
                    Spacer()
                    Button(action: {
                        print("Logout!")
                        GIDSignIn.sharedInstance()?.disconnect()
                    }) {
                        Text("Logout")
                            .bold()
                            .foregroundColor(.black)
                    }
                }.padding()
                TaskRow()
                GenericButton(isFilled: true, color: .orange, topText: Text("Save in CoreData")){
                    print("salvo in coredata")
                    CoreDataController.addTasks(tasks: self.shared.commitmentArray())
                }
                GenericButton(isFilled: true, color: .orange, topText: Text("Load from CoreData")){
                    print("leggo da coredata")
                    print(CoreDataController.getCachedTasks())
                }
                AddNeedButton()
            }
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.vertical)
    }
    
}
