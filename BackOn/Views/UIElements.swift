//
//  UIElements.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

let customDateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

var locAlert = Alert(
    title: Text("Location permission denied"),
    message: Text("To let the app work properly, enable location permissions"),
    primaryButton: .default(Text("Open settings")) {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    },
    secondaryButton: .cancel()
)

struct CloseButton: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        ZStack{
            Image(systemName: "circle.fill")
                .font(.title)
                .foregroundColor(Color(.systemGroupedBackground))
            Button(action: {
                withAnimation{
                    if self.shared.previousView == "HomeView" {
                        HomeView.show()
                    } else if self.shared.previousView == "LoginPageView"{
                        LoginPageView.show()
                    } else if self.shared.previousView == "CommitmentDetailedView"{
                        CommitmentDetailedView.show()
                    } else if self.shared.previousView == "DiscoverDetailedView"{
                        DiscoverDetailedView.show()
                    } else if self.shared.previousView == "CommitmentsListView"{
                        CommitmentsListView.show()
                    } else if self.shared.previousView == "AddNeedView"{
                        AddNeedView.show()
                    } else if self.shared.previousView == "NeederHomeView"{
                        NeederHomeView.show()
                    } else if self.shared.previousView == "FullDiscoverView"{
                        FullDiscoverView.show()
                    } else if self.shared.previousView == "NeedsListView"{
                        NeedsListView.show()
                    } else if self.shared.previousView == "LoadingPageView" {
                        LoadingPageView.show()
                    }
                }
            }){
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color(#colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.8, alpha: 1)))
            }
        }
    }
}

struct NeederButton: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        Button(action: {
            withAnimation{
                NeederHomeView.show()
                self.shared.helperMode = false
            }}){
                Image(systemName: "person")
                    .font(.largeTitle)
                    .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
        }
    }
}

struct ConfirmAddNeedButton: View {
    var insertFunction: () -> Void
    var body: some View {
        Button(action: {
            NeederHomeView.show()
            self.insertFunction()
        }) {
            HStack{
                Text("Confirm ")
                    .fontWeight(.regular)
                Image(systemName: "hand.thumbsup")
            }
            .font(.title)
            .padding(20)
            .background(Color.blue)
            .cornerRadius(40)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.blue, lineWidth: 1).foregroundColor(Color.blue)
            )
        }
    }
}

struct DoItButton: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    
    var body: some View {
        HStack{
            Spacer()
            Button(action: {
                print("I'll do it")
//                print("TEST: \(self.shared.selectedCommitment.userInfo.email!) and \(self.shared.selectedCommitment.ID)")
                let coreDataController = CoreDataController()
                self.dbController.insertCommitment(userEmail: coreDataController.getLoggedUser().1.email!, commitId: self.shared.selectedCommitment.ID)
                //self.shared.loading = true
            }) {
                HStack{
                    Text("I'll do it ")
                        .fontWeight(.regular)
                        .font(.title)
                    Image(systemName: "hand.raised")
                        .font(.title)
                }
                .padding(20)
                .background(Color(.systemBlue))
                .cornerRadius(40)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color(.systemBlue), lineWidth: 0).foregroundColor(Color(.systemBlue))
                )
            }.buttonStyle(PlainButtonStyle())
            Spacer()
        }
    }
    
}

struct CantDoItButton: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        HStack{
            Spacer()
            Button(action: {
                print("Can't do it")
                HomeView.show()
            }) {
                HStack{
                    Text("Can't do it ")
                        .fontWeight(.regular)
                        .font(.title)
                    Image(systemName: "hand.raised.slash")
                        .font(.title)
                }
                .padding(20)
                .background(Color(.systemRed))
                .cornerRadius(40)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color(.systemRed), lineWidth: 0).foregroundColor(Color(.systemRed))
                )
            }.buttonStyle(PlainButtonStyle())
            Spacer()
        }
    }
}

struct DontNeedAnymoreButton: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        HStack{
            Spacer()
            Button(action: {
                print("Don't Need Anymore")
                NeederHomeView.show()
            }) {
                HStack{
                    Text("Don't need anymore ")
                        .fontWeight(.regular)
                        .font(.title)
                    Image(systemName: "hand.thumbsup")
                        .font(.title)
                }
                .padding(20)
                .background(Color(.systemRed))
                .cornerRadius(40)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color(.systemRed), lineWidth: 0).foregroundColor(Color(.systemRed))
                )
            }.buttonStyle(PlainButtonStyle())
            Spacer()
        }
    }
}


struct AddNeedButton: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    var body: some View {
        HStack{
            Spacer()
            Button(action: {
                print("Need help!")
                AddNeedView.show()
            }) {
                HStack{
                    Text("Add Need ")
                        .fontWeight(.regular)
                        .font(.title)
                    Image(systemName: "person.2")
                        .font(.title)
                    
                }
                .padding(20)
                .background(Color.blue)
                .cornerRadius(40)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.blue, lineWidth: 1).foregroundColor(Color.blue)
                )
            }
            Spacer()
        }
    }
}


struct ElementPickerGUI: View {
    var pickerElements: [String]
    @Binding var selectedValue: Int
    
    var body: some View {
        Picker("Select your need", selection: self.$selectedValue) {
            ForEach(0 ..< self.pickerElements.count) {
                Text(self.pickerElements[$0])
                    .font(.headline)
                    .fontWeight(.medium)
            }
        }.labelsHidden()
            .frame(width: UIScreen.main.bounds.width, height: 250)
            .background(Color.primary.colorInvert())
    }
}

struct DatePickerGUI: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            DatePicker(selection: self.$selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {
                Text("Select a date")
            }.labelsHidden()
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .background(Color.primary.colorInvert())
        }.frame(width: UIScreen.main.bounds.width, height: 250)
            .background(Color.primary.colorInvert())
    }
}
