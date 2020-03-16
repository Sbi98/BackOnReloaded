//
//  UIElements.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit

let defaultButtonDimensions = (width: CGFloat(155.52), height: CGFloat(48))

let customDateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct CloseButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let discoverTabController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
    var externalColor = #colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)
    var internalColor = UIColor.systemGroupedBackground
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.presentationMode.wrappedValue.dismiss()
                self.discoverTabController.closeSheet()
                HomeView.show()
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


struct ConfirmAddNeedButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
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
    let task: Task
    
    var body: some View {
        GenericButton(
            isFilled: true,
            color: #colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1),
            topText: "I'll do it",
            bottomText: nil
        ) {
            (UIApplication.shared.delegate as! AppDelegate).dbController.insertCommitment(userEmail: CoreDataController.loggedUser!.email, commitId: self.task.ID)
        }
    }
}

struct CantDoItButton: View {
    
    var body: some View {
        GenericButton(
            isFilled: false,
            color: #colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1),
            topText: "Can't do it",
            bottomText: nil
        ) {
            print("Can't do it anymore!\nIMPLEMENTALO!")
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
                //NeederHomeView.show()
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
    @State var showModal = false
    var body: some View {
        Button(action: {self.showModal.toggle()}) {
            Image("AddNeedSymbol").foregroundColor(Color(.systemOrange)).imageScale(.large).font(.largeTitle)
        }.sheet(isPresented: $showModal, content: {AddNeedView()})
    }
}

struct ProfileButton: View {
    @State var showModal = false
    var body: some View {
        Button(action: {self.showModal.toggle()}) {
            Image(systemName: "person.crop.circle").foregroundColor(Color(.systemOrange)).font(.largeTitle)
        }.sheet(isPresented: $showModal, content: {HomeView()})
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
        DatePicker(selection: self.$selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {
            Text("Select a date")
        }
        .labelsHidden()
        .frame(width: UIScreen.main.bounds.width, height: 250)
        .background(Color.primary.colorInvert())
    }
}

struct DirectionsButton: View {
    let isFilled: Bool = false
    @ObservedObject var selectedTask: Task
    
    var body: some View {
        Button(action: {MapController.openInMaps(commitment: self.selectedTask)}){
            VStack{
                Text("Directions")
                    .fontWeight(.semibold)
                    .font(Font.custom("SF Pro Text", size: 17))
                    .foregroundColor(!isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                if selectedTask.etaText != "Calculating..." {
                    Text("\(selectedTask.etaText)")
                        .fontWeight(.regular)
                        .font(Font.custom("SF Pro Text", size: 15))
                        .foregroundColor(!isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }
            }
            .padding()
            .frame(width: defaultButtonDimensions.width, height: defaultButtonDimensions.height)
            .background(isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(!isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), lineWidth: 1))
        }.buttonStyle(PlainButtonStyle())
    }
    
}

struct GenericButton: View {
    var dimensions: (width: CGFloat, height: CGFloat) = defaultButtonDimensions
    var isFilled: Bool
    var color: UIColor = #colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)
    var topText: String
    var bottomText: String?
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(topText)
                    .fontWeight(.semibold)
                    .font(Font.custom("SF Pro Text", size: 17))
                    .foregroundColor(!isFilled ? Color(color) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                if bottomText != nil {
                    Text(bottomText!)
                        .fontWeight(.regular)
                        .font(Font.custom("SF Pro Text", size: 15))
                        .foregroundColor(!isFilled ? Color(color) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }
            }
            .padding()
            .frame(width: dimensions.width, height: dimensions.height)
            .background(isFilled ? Color(color) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(!isFilled ? Color(color) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), lineWidth: 1))
        }.buttonStyle(PlainButtonStyle())
    }
}

//let locAlert = Alert(
//    title: Text("Location permission denied"),
//    message: Text("To let the app work properly, enable location permissions"),
//    primaryButton: .default(Text("Open settings")) {
//        if let url = URL(string:UIApplication.openSettingsURLString) {
//            UIApplication.shared.open(url)
//        }
//    },
//    secondaryButton: .cancel()
//)
