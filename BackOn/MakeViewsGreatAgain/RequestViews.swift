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
                }.font(.body).tint(.gray)
            } else {
                Button(action: {withAnimation{RequestsListView.show()}}) {
                    HStack {
                        Text("Your requests")
                            .fontWeight(.bold)
                            .font(.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .orange()
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
        let isExpired = request.isExpired()
        let hasHelper = request.helperID != nil
        return Button(action: {self.showModal = true}) {
            VStack {
                ZStack {
                    VStack(spacing: 3){
                        Text(hasHelper ? self.shared.users[request.helperID!]?.identity ?? "Helper with bad id" : "Nobody accepted")
                            .fontWeight(.semibold)
                            .font(.system(size: 23))
                        Text(request.title)
                            .font(.body)
                        Text("\(request.date, formatter: customDateFormat)")
                            .tint(.taskGray)
                            .padding(.horizontal, 10)
                            .frame(width: 320, alignment: .trailing)
                    }
                    .tintIf(!hasHelper, .task, .white) //usa l'arancione del BG dei task per il testo delle request non accettate
                    .offset(y: 10)
                    .frame(width: 320, height: 110)
                    .backgroundIf(isExpired, .expiredTask, hasHelper ? .task : .white)
                    .overlayIf(.constant(!hasHelper && !isExpired), toOverlay: RoundedRectangle(cornerRadius: 10).stroke(Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)), lineWidth: 3))
                    .loadingOverlay(isPresented: $request.waitingForServerResponse)
                    .cornerRadius(10)
                    .shadow(color: Color(.systemGray3), radius: 3)
                    Avatar(hasHelper ? self.shared.users[request.helperID!] : nil, size: 75)
                        .blackOverlayIf($request.waitingForServerResponse)
                        .clipShape(Circle())
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
                        .font(.headline).orange()
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
