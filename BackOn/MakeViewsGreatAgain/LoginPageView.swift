//
//  ContentView.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 14/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct LoginPageView: View {
    var body: some View {
        VStack {
            Text("BackOn")
                .fontWeight(.bold).foregroundColor(.white)
                .font(.title)
                .padding([.top, .bottom], 40)
            
            Image("Icon")
                .resizable()
                .frame(width: 250, height: 250)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            Spacer()
            GoogleButton()
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width)
        .offset(y: 50)
        .background(Color(#colorLiteral(red: 0.9502732158, green: 0.6147753596, blue: 0.2734006643, alpha: 1)))
        .edgesIgnoringSafeArea(.all)
    }
}

struct LoadingPageView: View {
    var body: some View {
        VStack {
            Text("BackOn")
                .fontWeight(.bold).foregroundColor(.white)
                .font(.title)
                .padding([.top, .bottom], 40)
            
            Image("Icon")
                .resizable()
                .frame(width: 250, height: 250)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            Spacer()
            ActivityIndicator()
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width)
        .offset(y: 50)
        .background(Color(#colorLiteral(red: 0.9502732158, green: 0.6147753596, blue: 0.2734006643, alpha: 1)))
        .edgesIgnoringSafeArea(.all)
    }
}

struct GoogleButton: View {
    var body: some View {
        Button(action: {GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.first?.rootViewController; GIDSignIn.sharedInstance()?.signIn()}) {
            ZStack {
                RoundedRectangle(cornerRadius: 30).fill(Color(.white)).frame(width: 280, height: 60, alignment: .center)
                HStack (spacing: 20){
                    Image("GIcon").resizable().renderingMode(.original).scaledToFit()
                    Text("Sign in with Google").foregroundColor(.black)
                }.frame(width: 280, height: 30, alignment: .center)
            }
        }
    }
}
