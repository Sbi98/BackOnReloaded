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
            VStack {
                HStack{
                    Text("Hi \(CoreDataController.loggedUser!.name)!")
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
                GenericButton(isFilled: true, color: .systemOrange, topText: Text("Save in C.D.")){
                    print("salvo in coredata")
                    CoreDataController.addTasks(tasks: self.shared.commitmentArray())
                }
                Divider().hidden()
                GenericButton(isFilled: true, color: .systemOrange, topText: Text("Load from C.D.")){
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
