//
//  ContentView.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 14/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI
import GoogleSignIn

struct LoadingPageView: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
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
            ActivityIndicator(isAnimating: .constant(true), style: .large)
            Spacer()
        }
        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                (UIApplication.shared.delegate as! AppDelegate).shared.mainWindow = "CustomTabView"
//            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .offset(y: 50)
        .background(LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}


//struct MyAppleidButton: UIViewRepresentable {
//
//    func makeUIView(context: UIViewRepresentableContext<MyAppleidButton>) -> ASAuthorizationAppleidButton {
//        let appleButton = ASAuthorizationAppleidButton()
//        appleButton.translatesAutoresizingMaskIntoConstraints = false
//
//        return appleButton
//    }
//
//    func updateUIView(_ uiView: MyAppleidButton.UIViewType, context: UIViewRepresentableContext<MyAppleidButton>) {
//
//    }
//}



