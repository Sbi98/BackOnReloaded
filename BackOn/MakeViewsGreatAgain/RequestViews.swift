//
//  RequestViews.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 09/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import Foundation
import SwiftUI

struct RequestRow: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack {
            if shared.myRequests.isEmpty && shared.myExpiredRequests.isEmpty {
                Divider().hidden()
                HStack(spacing: 7) {
                    Spacer()
                    Text("Tap on")
                    Image("AddNeedSymbol").font(.title)
                    Text("to add a request")
                    Spacer()
                }.font(.body).foregroundColor(Color(.systemGray))
            } else {
                Button(action: {withAnimation{RequestsListView.show()}}) {
                    HStack {
                        Text("Your requests")
                            .fontWeight(.bold)
                            .font(.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundColor(Color(.systemOrange))
                    }.padding(.horizontal, 20)
                }.buttonStyle(PlainButtonStyle())
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(shared.arrayFromSet(mode: .RequestViews), id: \._id) { currentRequest in
                            RequestView(request: currentRequest)
                        }
                        ForEach(shared.arrayFromSet(mode: .RequestViews, expiredSet: true), id: \._id) { currentRequest in
                            RequestView(request: currentRequest)
                        }
                    }
                    .padding(.horizontal, 20)
                }.offset(y: -10)
            }
        }
    }
}

struct RequestView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    @ObservedObject var request: Request
    @State var showModal = false
    
    var body: some View {
        Button(action: {self.showModal = true}) {
            VStack {
                ZStack {
                    VStack(spacing: 3){
                        Text(request.helperID == nil ? "Nobody accepted" : self.shared.users[request.helperID!]?.identity ?? "Helper with bad id")
                            .fontWeight(.semibold)
                            .font(.system(size: 23))
                            .foregroundColor(.white)
                        Text(request.title)
                            .font(.body)
                            .foregroundColor(.white)
                        Text("\(request.date, formatter: customDateFormat)")
                            .foregroundColor(Color.secondary)
                            .padding(.horizontal, 10)
                            .frame(width: 320, alignment: .trailing)
                    }.offset(y: 10)
                        .frame(width: 320, height: 110)
                        .background(request.isExpired() ? Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)) : Color(UIColor(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1))))
                        .cornerRadius(10)
                        .shadow(color: Color(.systemGray3), radius: 3)
                    Avatar(image: (request.helperID == nil ? nil : self.shared.users[request.helperID!]?.profilePic), size: 75)
                        .offset(y: -70)
                        .shadow(color: Color(.systemGray3), radius: 3)
                }
            }.frame(height: 185).offset(y: 30)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: self.$showModal) {DetailedView(requiredBy: .RequestViews, selectedTask: self.request)}
    }
    
}

struct RequestsListView: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Button(action: {withAnimation{HomeView.show()}}) {
                HStack(spacing: 15) {
                    Image(systemName: "chevron.left")
                        .font(.headline).foregroundColor(Color(.systemOrange))
                    Text("Your requests")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                }.padding([.top,.horizontal])
            }.buttonStyle(PlainButtonStyle())
            ListView(mode: .RequestViews)
            Spacer()
        }
    }
}

//struct RequestView_Previews: PreviewProvider {
//    static var previews: some View {
//        RequestView(request: Task(neederUser: User(name: "Gio", surname: "Fal", email: "giancarlosorrentino99@gmail.com", photoURL: URL(string: "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3400&q=80")!, isHelper: 0), title: "Prova", descr: "Prova", date: Date(), latitude: 41, longitude: 15, id: 2))
//    }
//}
