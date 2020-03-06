//
//  TaskViews.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 06/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject var commitment: Commitment
    
    var body: some View {
        ZStack (alignment: .bottom){
            MapView(mode: .TaskTab, selectedCommitment: commitment)
            VStack (spacing: 2){
                ZStack {
                    Image("cAnnotation")
                        .foregroundColor(Color(UIColor.systemOrange))
                        .offset(y: -5)
                        .scaleEffect(0.97)
                    Avatar(image: commitment.userInfo.profilePic)
                        .offset(y: -9.65)
                }.scaleEffect(1.2)
                Text(commitment.userInfo.name)
                    .foregroundColor(Color.white)
                    .background(Rectangle().cornerRadius(10).scaleEffect(1.15).foregroundColor(Color(UIColor.systemOrange)))
                    .scaleEffect(0.95)
            }.offset(y: -130)
            VStack (spacing: 5){
               Text(self.commitment.title)
                   .font(.title)
                   .fontWeight(.light)
                   .foregroundColor(Color.primary)
               //Text(self.commitment.city).onAppear{self.commitment.locate()}
               Text("\(self.commitment.date, formatter: customDateFormat)")
                   .foregroundColor(Color.secondary)
                   .padding(.horizontal, 10)
                   .frame(width: 320, alignment: .trailing)
           }.frame(width: 320, height: 80).background(Color(.systemOrange)).cornerRadius(10)
        }
        .frame(width: 320, height: 350)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct TaskRow: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack (alignment: .leading) {
            Button(action: {
                withAnimation{
                    CommitmentsListView.show()
                }
            }) {
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
                    ForEach(shared.commitmentArray(), id: \.ID) { currentCommitment in
                        TaskView(commitment: currentCommitment)
                    }
                }
                .padding(20)
            }.offset(x: 0, y: -20)
        }
    }
}
