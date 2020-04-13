////
////  Certificates.swift
////  BackOn
////
////  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 11/02/2020.
////  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
////
//



//struct ConfirmAddNeedButton: View {
//    var action: () -> Void
//    var body: some View {
//        Button(action: {self.action()}) {
//            HStack{
//                Text("Confirm ")
//                Image(systemName: "hand.thumbsup")
//            }
//            .font(.title)
//            .padding(20)
//            .background(Color.blue)
//            .cornerRadius(40)
//            .foregroundColor(.white)
//            .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1).foregroundColor(Color.blue))
//        }
//    }
//}

//import SwiftUI
//
//struct NeedView: View {
//    @ObservedObject var need: Task
//    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
//
//    var body: some View {
//        Button(action: {
//            withAnimation {
//                self.shared.selectedCommitment = self.need
//                NeedDetailedView.show()
//            }
//        }) {
//            VStack (alignment: .leading, spacing: 5){
//                UserPreview(user: need.neederUser, whiteText: self.darkMode)
//                Spacer()
//                Text(need.title)
//                    .font(.title)
//                    .fontWeight(.regular)
//                    .foregroundColor(.primary)
//                Text(need.descr)
//                    .font(.headline)
//                    .fontWeight(.regular)
//                    .foregroundColor(.primary)
//                Spacer()
//                Text(self.shared.dateFormatter.string(from: self.need.date)).foregroundColor(Color.secondary).frame(width: 300, alignment: .trailing)
//            }
//            .padding(10)
//            .padding(.leading, 5)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .frame(width: 330, height: 230)
//        .background(Color.primary.colorInvert())
//        .cornerRadius(10)
//        .shadow(radius: 10)
//    }
//}
//
//
//struct NeedsRow: View {
//    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
//
//    var body: some View {
//        VStack (alignment: .leading) {
//            Button(action: {
//                withAnimation {
//                    NeedsListView.show()
//                }
//            }) {
//                HStack {
//                    Text("Your requests")
//                        .fontWeight(.bold)
//                        .font(.title)
//                    Spacer()
//                    Image(systemName: "chevron.right")
//                        .font(.headline)
//                        .foregroundColor(Color(UIColor.systemBlue))
//                }.padding(.horizontal, 20)
//            }.buttonStyle(PlainButtonStyle())
//
//            if shared.needArray().isEmpty{
//                Text("You have no needs")
//                    .font(.headline)
//                    .padding(.horizontal, 50)
//            } else {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 20) {
//                        ForEach(shared.needArray(), id: \._id) { currentDiscover in
//                            NeedView(need: currentDiscover).frame(width: 330, height: 230)
//                        }
//                    }.padding(20)
//                }.offset(x: 0, y: -20)
//            }
//        }
//    }
//}
//
//struct NeedsListView: View {
//    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
//    
//    var body: some View {
//        VStack (alignment: .leading, spacing: 10){
//            Button(action: {withAnimation{NeederHomeView.show()}}) {
//                HStack {
//                    Image(systemName: "chevron.left")
//                        .font(.headline).foregroundColor(Color(UIColor.systemBlue))
//                    Text("Your needs")
//                        .fontWeight(.bold)
//                        .font(.title)
//                        .padding(.leading, 5)
//                    Spacer()
//                }.padding([.top,.horizontal])
//                }.buttonStyle(PlainButtonStyle())
//            
//            RefreshableScrollView(height: 80, refreshing: self.$shared.loading) {
//                VStack (alignment: .center, spacing: 25){
//                    ForEach(shared.needArray(), id: \._id) { currentCommitment in
//                        Button(action: {withAnimation{
//                            self.shared.selectedCommitment = currentCommitment
//                            NeedDetailedView.show()
//                            }}) {
//                                HStack {
//                                    UserPreview(user: currentCommitment.neederUser, description: currentCommitment.title, whiteText: self.darkMode)
//                                    Spacer()
//                                    Image(systemName: "chevron.right")
//                                        .font(.headline)
//                                        .foregroundColor(Color(UIColor.systemBlue))
//                                }.padding(.horizontal, 15)
//                        }.buttonStyle(PlainButtonStyle())
//                    }
//                }.padding(.top,20)
//            }
//            Spacer()
//        }
//        .padding(.top, 40)
//        .background(Color.primary.colorInvert())
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//
//
//
