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
                    Text("Hi \(CoreDataController().getLoggedUser().1.name)!")
                        .font(.largeTitle)
                        .bold()
                        .fontWeight(.heavy)
//                        .padding(.horizontal)
//                        .padding(.top)
//                        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
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
//                    .frame(width: UIScreen.main.bounds.width, height: CGFloat(400), alignment: .top)
                //DiscoverRow().frame(width: UIScreen.main.bounds.width, height: CGFloat(200), alignment: .top).padding(80)
//                Spacer()
            }
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.vertical)
    }
    
}
