//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit

struct CommitmentView: View {
    @EnvironmentObject var shared: Shared
    
    var commitment: Commitment
    
    var body: some View {
        VStack {
            MapViewCommitment(key: commitment.ID)
                .frame(height: 250)
            Button(action: {
                withAnimation {
                    self.shared.selectedCommitment = self.commitment
                    CommitmentDetailedView.show()
                }
            }) {
                VStack{
                    Avatar(image: commitment.userInfo.profilePic)
                    //                    Avatar(image: "\(commitment.userInfo.photo)", size: 60)
                    Spacer()
                    Text(self.commitment.userInfo.identity)
                        .font(.title)
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(self.commitment.title).foregroundColor(Color.primary)
                    Spacer()
                    Text(self.shared.dateFormatter.string(from: self.commitment.date)).foregroundColor(Color.secondary).padding(.horizontal, 10).offset(y:15).frame(width: 320, alignment: .trailing)
                }.offset(x: 0, y: -30)
            }.buttonStyle(PlainButtonStyle())
        }
        .frame(width: CGFloat(320), height: CGFloat(400))
        .background(Color.primary.colorInvert())
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct CommitmentRow: View {
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        VStack (alignment: .leading){
            Button(action: {
                withAnimation{
                    CommitmentsListView.show()
                }
            }) {
                HStack {
                    Text("Your commitments")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBlue))
                }.padding(.horizontal, 20)
            }.buttonStyle(PlainButtonStyle())
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(shared.commitmentArray(), id: \.ID) { currentCommitment in
                        CommitmentView(commitment: currentCommitment)
                    }
                }
                .padding(20)
            }.offset(x: 0, y: -20)
        }.frame(width: UIScreen.main.bounds.width, height: CGFloat(400), alignment: .top)
    }
}


struct CommitmentsListView: View {
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Button(action: {withAnimation{
                print("CIAO\n\n\n")
                HomeView.show()}}) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.headline).foregroundColor(Color(UIColor.systemBlue))
                    
                    Text("Your commitments")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding(.leading, 5)
                    Spacer()
                }.padding([.top,.horizontal])
            }.buttonStyle(PlainButtonStyle())
            RefreshableScrollView(height: 70, refreshing: self.$shared.loading) {
                VStack (alignment: .center, spacing: 25){
                    ForEach(shared.commitmentArray(), id: \.ID) { currentCommitment in
                        Button(action: {withAnimation{
                            self.shared.selectedCommitment = currentCommitment
                            CommitmentDetailedView.show()
                            }}) {
                                HStack {
                                    UserPreview(user: currentCommitment.userInfo, description: currentCommitment.title, whiteText: self.shared.darkMode)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemBlue))
                                }.padding(.horizontal, 15)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.top,20)
            }
            Spacer()
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
}

