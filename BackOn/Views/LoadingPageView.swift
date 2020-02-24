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
    @EnvironmentObject var shared: Shared
    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    
    var body: some View {
        VStack {
            
           
            HStack() {
                Spacer()
            }
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
            
            ActivityIndicator(isAnimating: .constant(true), style: .large).padding(50)
            
            Spacer()
            
            
            }
            .onAppear(perform: {
                self.shared.loading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if self.shared.helperMode {
                        HomeView.show()
                    } else {
                        NeederHomeView.show()
                    }
                }
            })
            .background(LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all))
    }
}



//struct MyAppleIDButton: UIViewRepresentable {
//
//    func makeUIView(context: UIViewRepresentableContext<MyAppleIDButton>) -> ASAuthorizationAppleIDButton {
//        let appleButton = ASAuthorizationAppleIDButton()
//        appleButton.translatesAutoresizingMaskIntoConstraints = false
//
//        return appleButton
//    }
//
//    func updateUIView(_ uiView: MyAppleIDButton.UIViewType, context: UIViewRepresentableContext<MyAppleIDButton>) {
//
//    }
//}


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

//struct LoadingView: View {
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .center) {
//
//
//
//                VStack {
//                    ActivityIndicator(isAnimating: .constant(true), style: .large)
//                }
//                .frame(width: geometry.size.width / 2,
//                       height: geometry.size.height / 5)
//                .background(Color.secondary.colorInvert())
//                .foregroundColor(Color.primary)
//                .cornerRadius(20)
//                .opacity(self.isShowing ? 1 : 0)
//
//            }
//        }
//    }
//
//}

