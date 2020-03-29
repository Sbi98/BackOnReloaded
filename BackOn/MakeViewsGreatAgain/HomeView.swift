//
//  HomeView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            HStack (alignment: .center, spacing: 10) {
                Text("Hi \(CoreDataController.loggedUser!.name)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                ProfileButton()
                AddNeedButton()
            }.padding(.horizontal).padding(.top, 10)
            ScrollView {
                TaskRow()
                RequestRow()
            }
        }
    }
}
