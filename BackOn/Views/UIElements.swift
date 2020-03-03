//
//  UIElements.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit

let defaultDimensions = (width: CGFloat(155.52), height: CGFloat(48))

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
    var externalColor = #colorLiteral(red: 0.9281502366, green: 0.8382813334, blue: 0.6886059642, alpha: 1)
    var internalColor = UIColor.systemGroupedBackground
    var body: some View {
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
            ZStack{
                Image(systemName: "circle.fill")
                    .font(.title)
                    .foregroundColor(Color(internalColor)).scaleEffect(1.15)
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color(externalColor))
            }
        }.buttonStyle(PlainButtonStyle())
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
            .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1).foregroundColor(Color.blue))
        }
    }
}

struct DoItButton: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    
    var body: some View {
        GenericButton(
            isFilled: true,
            color: #colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1),
            topText: Text("I'll do it").font(Font.custom("SF Pro Text", size: 15)),
            bottomText: nil
        ) {
            let coreDataController = CoreDataController()
            self.dbController.insertCommitment(userEmail: coreDataController.getLoggedUser().1.email!, commitId: self.shared.selectedCommitment.ID)
            //self.shared.loading = true
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
                .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color(.systemRed), lineWidth: 0).foregroundColor(Color(.systemRed)))
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
                .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color(.systemRed), lineWidth: 0).foregroundColor(Color(.systemRed)))
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
                .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1).foregroundColor(Color.blue)
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
        }
        .labelsHidden()
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
            }
            .labelsHidden()
            .frame(width: UIScreen.main.bounds.width, height: 250)
            .background(Color.primary.colorInvert())
        }.frame(width: UIScreen.main.bounds.width, height: 250)
            .background(Color.primary.colorInvert())
    }
}

struct OpenInMapsButton: View {
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    var isFilled: Bool
    let selectedCommitment: Commitment
    var body: some View {
        GenericButton(
            dimensions: defaultDimensions,
            isFilled: isFilled,
            color:#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1),
            topText: Text("Directions").fontWeight(.semibold).font(Font.custom("SF Pro Text", size: 15)),
            bottomText: selectedCommitment.etaText != "Calculating..." ? Text(selectedCommitment.etaText).fontWeight(.regular).font(Font.custom("SF Pro Text", size: 15)) : nil
        ){
            self.mapController.openInMaps(commitment: self.selectedCommitment)
        }
    }
}

struct GenericButton: View {
    var dimensions: (width: CGFloat, height: CGFloat) = defaultDimensions
    var isFilled: Bool
    var color: UIColor
    var topText: Text
    var bottomText: Text?
    var insertFunction: () -> Void
    
    var body: some View{
        Button(action: insertFunction){
            VStack{
                topText.foregroundColor(!isFilled ? Color(color) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                if bottomText != nil {
                    bottomText!.foregroundColor(!isFilled ? Color(color) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }
            }
            .padding()
            .frame(width: dimensions.width, height: dimensions.height)
            .background(isFilled ? Color(color) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(!isFilled ? Color(color) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), lineWidth: 1))
        }.buttonStyle(PlainButtonStyle())
    }
}

struct OpenInMapsButton_Previews: PreviewProvider {
    static var previews: some View {
        OpenInMapsButton(isFilled: true, selectedCommitment: Commitment(userInfo: UserInfo(name: "Giancarlo", surname: "Sorrentino", email: "giancarlosorrentino99@gmail.com", photoURL: URL(string: "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3400&q=80")!, isHelper: 0), title: "Ho mal di testa", descr: "Ho bevuto troppo e sono in hangover, che posso farci? Devo andare in farmacia a prendere una moment ma non ho le forze.", date: Date(), position: CLLocation(latitude: 41, longitude: 15), ID: 2))
    }
}

