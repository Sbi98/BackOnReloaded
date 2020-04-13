//
//  HomeView.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 12/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
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
