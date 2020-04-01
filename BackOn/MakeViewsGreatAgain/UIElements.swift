//
//  UIElements.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit
import GoogleSignIn

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
    var body: some View {
        Button(action: {
            withAnimation {
                self.presentationMode.wrappedValue.dismiss()
                self.discoverTabController.closeSheet()
                HomeView.show()
            }
        }){
            Image(systemName: "xmark.circle.fill").font(.largeTitle).foregroundColor(Color(.systemGray))
        }.buttonStyle(PlainButtonStyle())
    }
}

struct ConfirmAddNeedButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: {self.action()}) {
            HStack{
                Text("Confirm ")
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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let task: Task
    var body: some View {
        GenericButton(
            isFilled: true,
            topText: "I'll do it"
        ) {
            DatabaseController.addTask(toAccept: self.task){ error in
                guard error == nil else {print(error!); return}
                var user: User?
                self.task.helperID = CoreDataController.loggedUser!._id
                MapController.getSnapshot(location: self.task.position.coordinate){ snapshot, error in
                    guard error == nil, let snapshot = snapshot else {CoreDataController.addTask(task: self.task);return}
                    self.task.mapSnap = snapshot.image
                    CoreDataController.addTask(task: self.task)
                }
                DispatchQueue.main.sync {
                    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                    let neederID = self.task.neederID
                    shared.myTasks[self.task._id] = self.task
                    user = shared.discUsers[neederID]
                    if shared.users[neederID] == nil {
                        shared.users[neederID] = user
                    }
                }
                self.presentationMode.wrappedValue.dismiss()
                if user != nil {
                    CoreDataController.addUser(user: user!)
                }
            }
        }
    }
}

struct CantDoItButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let task: Task
    var body: some View {
        GenericButton(
            isFilled: true,
            topText: "Can't do it"
        ) {
            DatabaseController.removeTask(taskid: self.task._id){ error in
                guard error == nil else {print(error!); return}
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).shared.myTasks[self.task._id] = nil
                }
                self.presentationMode.wrappedValue.dismiss()
                CoreDataController.deleteTask(task: self.task)
            }
        }
    }
}

struct DontNeedAnymoreButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let request: Task
    var body: some View {
        GenericButton(
            isFilled: true,
            isLarge: true,
            topText: "Don't need anymore"
        ) {
            DatabaseController.removeRequest(requestid: self.request._id){ error in
                guard error == nil else {print(error!); return}
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).shared.myRequests[self.request._id] = nil
                }
                self.presentationMode.wrappedValue.dismiss()
                CoreDataController.deleteTask(task: self.request)
            }
        }
    }
}

struct ThankButton: View {
    let task: Task
    var body: some View {
        GenericButton(
            isFilled: true,
            topText: "Thank you"
        ) {
            DatabaseController.stashTask(
                toStash: self.task,
            report: "Thank you!"
            ){ error in
            guard error == nil else {print(error!); return}
                DispatchQueue.main.async {
                }
            }
        }
    }
}

struct ReportButton: View {
    @State var showActionSheet: Bool = false
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Report a problem"), message: Text("Choose Option"), buttons: [
            .default(Text("The helper didn't show up")) {
                DatabaseController.stashTask(
                    toStash: self.task,
                report: "Didn't show up"
                ){ error in
                guard error == nil else {print(error!); return}
                    DispatchQueue.main.async {
                    }
                }
            },
            .default(Text("The helper had bad manners")) {
                DatabaseController.stashTask(
                    toStash: self.task,
                report: "Bad manners"
                ){ error in
                guard error == nil else {print(error!); return}
                    DispatchQueue.main.async {
                    }
                }
            },
            .destructive(Text("Cancel report"))
        ])
    }
    let task: Task
    var body: some View {
        GenericButton(
            isFilled: false,
            topText: "Report"
        ){self.showActionSheet.toggle()}
        .actionSheet(isPresented: $showActionSheet){self.actionSheet}
    }
}

struct AddNeedButton: View {
    @State var showModal = false
    var body: some View {
        Button(action: {self.showModal.toggle()}) {
            Image("AddNeedSymbol")
                .foregroundColor(Color(.systemOrange))
                .imageScale(.large)
                .font(.largeTitle)
        }.sheet(isPresented: $showModal){AddNeedView()}
    }
}

struct ProfileButton: View {
    @State var showModal = false
    var body: some View {
        Button(action: {print("Logout!");GIDSignIn.sharedInstance()?.disconnect()}) {
            Image(systemName: "person.crop.circle").foregroundColor(Color(.systemOrange)).font(.largeTitle)
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
        DatePicker("",selection: self.$selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
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
            VStack {
                Text("Directions")
                    .fontWeight(.semibold)
                    .font(.body)
                    .foregroundColor(!isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                if selectedTask.etaText != "Calculating..." {
                    Text("\(selectedTask.etaText)")
                        .font(.subheadline)
                        .foregroundColor(!isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }
            }
            .frame(width: defaultButtonDimensions.width, height: defaultButtonDimensions.height)
            .background(isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(!isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), lineWidth: 1))
        }.buttonStyle(PlainButtonStyle())
    }
}

struct GenericButton: View {
    var dimensions: (width: CGFloat, height: CGFloat) = defaultButtonDimensions
    var isFilled: Bool
    var isLarge: Bool = false
    var color: UIColor = #colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)
    var topText: String
    var bottomText: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(topText)
                    .fontWeight(.semibold)
                    .font(.body)
                    .foregroundColor(!isFilled ? Color(color) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                if bottomText != nil {
                    Text(bottomText!)
                        .font(.subheadline)
                        .foregroundColor(!isFilled ? Color(color) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }
            }
            .frame(width: isLarge ? dimensions.width*2 : dimensions.width, height: dimensions.height)
            .background(isFilled ? Color(color) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(!isFilled ? Color(color) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), lineWidth: 1))
        }.buttonStyle(PlainButtonStyle())
    }
}

