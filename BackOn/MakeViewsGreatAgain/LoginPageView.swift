//
//  ContentView.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 14/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct LoginPageView: View {
    @ObservedObject var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        VStack {
            Text("BackOn")
                .fontWeight(.bold).foregroundColor(.white)
                .font(.title)
                .padding([.top, .bottom], 40)
            
            Image("iosapptemplate")
                .resizable()
                .frame(width: 250, height: 250)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            
            Spacer()
            VStack {
                Text("How would you use the app?").font(.headline).colorInvert()
                Picker(selection: self.$shared.helperMode, label: Text("Helper or needer")) {
                    Text("Helper").tag(true)
                    Text("Needer").tag(false)
                }.pickerStyle(SegmentedPickerStyle()).labelsHidden()
                .frame(width: 200, height: 30, alignment: .center)
            }
            Spacer()
            GoogleButton()
                .frame(width: 200, height: 30, alignment: .center)
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width)
        .offset(y: 50)
        .background(LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}


struct GoogleButton: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<GoogleButton>) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.colorScheme = .light
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        
        return button
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: UIViewRepresentableContext<GoogleButton>) {
    }
}
