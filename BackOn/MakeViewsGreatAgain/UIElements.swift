//
//  UIElements.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 12/02/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI
import MapKit
import UIKit
import GoogleSignIn
import TOCropViewController

let defaultButtonDimensions = (width: CGFloat(155.52), height: CGFloat(48))

let customDateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct CloseButton: View {
    @Environment(\.presentationMode) var presentationMode
    let discoverTabController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
    var body: some View {
        Button(action: {
            withAnimation {
                self.presentationMode.wrappedValue.dismiss()
                self.discoverTabController.closeSheet()
                HomeView.show()
            }
        }){
            Image(systemName: "xmark.circle.fill").font(.largeTitle).tint(.white).opacity(0.9)
        }.buttonStyle(PlainButtonStyle())
    }
}


struct DoItButton: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var task: Task
    @State var showAlert = false
    
    
    var body: some View {
        GenericButton(
            isFilled: true,
            topText: "I'll do it"
        ) {
            let neederID = self.task.neederID
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
                self.task.waitingForServerResponse = true
                let discController = (UIApplication.shared.delegate as! AppDelegate).discoverTabController
                discController.showSheet = false
                if let annotation = discController.baseMKMap?.selectedAnnotations.first { discController.baseMKMap?.removeAnnotation(annotation) }
            }
            DatabaseController.addTask(toAccept: self.task){ error in
                
                DispatchQueue.main.async { self.task.waitingForServerResponse = false }
                guard error == nil else {print(error!);
                DispatchQueue.main.sync {
                    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                    shared.myDiscoverables[self.task._id] = nil
                    let alert = UIAlertController(title: "Oh no!", message: "It seems that this request was already accepted by another user.\nThank you anyway for your help and support, we really apreciate it.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Got it!", style: .default))
                    UIViewController.main?.present( alert, animated: true)
                    }
                   return}
                var user: User?
                self.task.helperID = CoreDataController.loggedUser!._id
                MapController.getSnapshot(location: self.task.position.coordinate, style: .dark){ snapshot, error in
                    if error == nil, let snapshot = snapshot { DispatchQueue.main.async{self.task.darkMapSnap = snapshot.image} }
                }
                MapController.getSnapshot(location: self.task.position.coordinate, style: .light){ snapshot, error in
                    if error == nil, let snapshot = snapshot { DispatchQueue.main.async{self.task.lightMapSnap = snapshot.image} }
                }
                // uso una dispatchqueue per dare il tempo di fare il download dello snapshot
                DispatchQueue(label: "addTask", qos: .utility).asyncAfter(deadline: .now() + 3) {
                    CoreDataController.addBond(self.task)
                }
                DispatchQueue.main.sync {
                    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                    shared.myTasks[self.task._id] = self.task
                    user = shared.discUsers[neederID]
                    if shared.users[neederID] == nil {
                        shared.users[neederID] = user
                    }
                    shared.myDiscoverables[self.task._id] = nil
                }
                if user != nil {
                    CoreDataController.addUser(user: user!)
                    let _ = CalendarController.addTask(task: self.task, needer: user!)
                }
            }
        }
    }
}

struct CantDoItButton: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var task: Task
    var body: some View {
        GenericButton(
            isFilled: true,
            topText: "Can't do it"
        ) {
            DispatchQueue.main.async { self.presentationMode.wrappedValue.dismiss(); self.task.waitingForServerResponse = true }
            DatabaseController.removeTask(toRemove: self.task){ error in
                DispatchQueue.main.async { self.task.waitingForServerResponse = false}
                guard error == nil else {print(error!); return}
                DispatchQueue.main.async { (UIApplication.shared.delegate as! AppDelegate).shared.myTasks[self.task._id] = nil }
                CoreDataController.deleteBond(self.task)
            }
            let _ = CalendarController.remove(self.task)
        }
    }
}

struct DontNeedAnymoreButton: View {
    @Environment(\.presentationMode) var presentationMode
    let request: Request
    var body: some View {
        GenericButton(
            isFilled: true,
            isLarge: true,
            topText: "Don't need anymore"
        ) {
            DispatchQueue.main.async { self.presentationMode.wrappedValue.dismiss(); self.request.waitingForServerResponse = true  }
            DatabaseController.removeRequest(toRemove: self.request){ error in
                guard error == nil else {print(error!); return}
                DispatchQueue.main.async { (UIApplication.shared.delegate as! AppDelegate).shared.myRequests[self.request._id] = nil }
                CoreDataController.deleteBond(self.request)
                let _ = CalendarController.remove(self.request)
            }
        }
    }
}

struct AskAgainButton: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let request: Task
    var body: some View {
        GenericButton(
            isFilled: true,
            isLarge: true,
            topText: "Ask again"
        ) {
            UIViewController.main?.presentedViewController?.dismiss(animated: true) { UIViewController.main?.present(CustomHostingController(contentView: AddRequestView(titlePickerValue: Souls.categories.firstIndex(of: self.request.title) ?? -1, requestDescription: self.request.descr ?? "", address: self.request.address), modalPresentationStyle: .formSheet, preventModalDismiss: true), animated: true)}
        }
    }
}


struct ThankButton: View {
    @Environment(\.presentationMode) var presentationMode
    let helperToReport: Bool
    let task: Task
    var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    var body: some View {
        GenericButton(
            isFilled: true,
            topText: helperToReport ? "Thank you" : "I feel better"
        ) {
            DispatchQueue.main.async { self.presentationMode.wrappedValue.dismiss() }
            CoreDataController.deleteBond(self.task)
            DatabaseController.reportTask(task: self.task, report: "Thank you!", helperToReport: self.helperToReport){ error in
                guard error == nil else {print(error!); return}
                DispatchQueue.main.async {
                    let _ = CoreDataController.loggedUser!._id == self.task.neederID ? self.shared.myExpiredRequests.removeValue(forKey: self.task._id) : self.shared.myExpiredTasks.removeValue(forKey: self.task._id)
                }
            }
        }
    }
}

struct ReportButton: View {
    @State var showActionSheet: Bool = false
    @Environment(\.presentationMode) var presentationMode
    let helperToReport: Bool
    var shared = (UIApplication.shared.delegate as! AppDelegate).shared
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Report a problem"), message: Text("Choose Option"), buttons: [
            .default(Text("The person didn't show up")) {
                    DispatchQueue.main.async { self.presentationMode.wrappedValue.dismiss() }
                CoreDataController.deleteBond(self.task)
                DatabaseController.reportTask(task: self.task, report:  "Didn't show up", helperToReport: self.helperToReport){ error in
                    guard error == nil else {print(error!); return}
                    DispatchQueue.main.async {
                        let _ = CoreDataController.loggedUser!._id == self.task.neederID ? self.shared.myExpiredRequests.removeValue(forKey: self.task._id) : self.shared.myExpiredTasks.removeValue(forKey: self.task._id)
                    }
                }
            },
            .default(Text("The person had bad manners")) {
                CoreDataController.deleteBond(self.task)
                DatabaseController.reportTask(task: self.task, report: "Bad manners", helperToReport: self.helperToReport){ error in
                    guard error == nil else {print(error!); return}
                    DispatchQueue.main.async {
                        let _ = CoreDataController.loggedUser!._id == self.task.neederID ? self.shared.myExpiredRequests.removeValue(forKey: self.task._id) : self.shared.myExpiredTasks.removeValue(forKey: self.task._id)
                    }
                }
            },
            .destructive(Text("Cancel"))
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
    @EnvironmentObject var underlyingVC: ViewControllerHolder
    var body: some View {
        Button(action: {self.underlyingVC.presentViewInChildVC(AddRequestView(), modalPresentationStyle: .formSheet)}) {
            Image("AddNeedSymbol").orange().font(.largeTitle).imageScale(.large)
        }
    }
}

struct ProfileButton: View {
    @EnvironmentObject var underlyingVC: ViewControllerHolder
    var body: some View {
        Button(action: {self.underlyingVC.presentViewInChildVC(ProfileView(), modalPresentationStyle: .formSheet)}) {
            Image(systemName: "person.crop.circle").orange().font(.largeTitle)
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
    @Binding var showBusyWarning: Bool
    
    var body: some View {
        let dateBinding: Binding<Date> = Binding(
            get: {self.selectedDate},
            set: { newDate in
                self.selectedDate = newDate
                self.showBusyWarning = CalendarController.isBusy(when: newDate)
            }
        )
        return VStack (spacing: 0){
            DatePicker("",selection: dateBinding, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .frame(width: UIScreen.main.bounds.width)
            if showBusyWarning { Text("You seem busy, check the calendar").tint(.yellow).offset(y: -5)}
            Spacer()
        }.frame(width: UIScreen.main.bounds.width, height: 260).background(Color.primary.colorInvert())
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
            .background(isFilled ? Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)).opacity(0.9) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(!isFilled ? Color(#colorLiteral(red: 0.9058823529, green: 0.7019607843, blue: 0.4156862745, alpha: 1)) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), lineWidth: 1))
        }.buttonStyle(PlainButtonStyle())
    }
}

struct CallButton: View {
    var phoneNumber: String?
    var date: Date
    var body: some View {
        let hoursLeft = (date.timeIntervalSinceNow - 18_000)/3_600
        let daysLeft = Int(hoursLeft/24)
        let dayString: String? = daysLeft > 0 ? "\(daysLeft) " + (daysLeft > 1 ? "days" : "day") : nil
        let hourString: String? = hoursLeft > 1 ? "\(Int(hoursLeft)) " + (hoursLeft > 2 ? "hrs" : "hr") : nil
        let disabledCondition = self.phoneNumber == nil || hoursLeft > 0
        return Button(action: {
            guard let phoneNumber = self.phoneNumber, let number = URL(string: "tel://" + phoneNumber) else { return }
            UIApplication.shared.open(number)
        }) {
            HStack {
                if self.phoneNumber == nil {
                    Image(systemName: "phone.down.fill").tintIf(self.phoneNumber == nil, .red, .green)
                    Text("Phone number not available")
                        .fontWeight(.semibold)
                        .font(.body)
                        .tint(.red)
                } else {
                    if hoursLeft <= 0 {
                        Image(systemName: "phone.fill").tintIf(self.phoneNumber == nil, .red, .green)
                        Text("Call")
                            .fontWeight(.semibold)
                            .font(.body)
                            .tint(.green)
                    } else {
                        Image(systemName: "phone.down.fill").tint(.red)
                        if dayString != nil {
                            Text("Available in " + dayString!)
                                .fontWeight(.semibold)
                                .font(.body)
                                .tint(.red)
                        } else if hourString != nil{
                            Text("Available in about " + hourString!)
                            .fontWeight(.semibold)
                            .font(.body)
                            .tint(.red)
                        } else {
                            Text("Available in less than 1 hr")
                                .fontWeight(.semibold)
                                .font(.body)
                                .tint(.red)
                        }
                    }
                }
            }
            .frame(width: defaultButtonDimensions.width*2, height: defaultButtonDimensions.height)
            .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(disabledCondition ? Color(.systemRed) : Color(.systemGreen), lineWidth: 1))
        }.buttonStyle(PlainButtonStyle()).disabled(disabledCondition)
    }
}


struct GenericButton: View {
    var dimensions: (width: CGFloat, height: CGFloat) = defaultButtonDimensions
    var isFilled: Bool
    var isLarge: Bool = false
    var color: Color = Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)).opacity(0.9)
    var topText: String
    var bottomText: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(topText)
                    .fontWeight(.semibold)
                    .font(.body)
                    .foregroundColor(!isFilled ? color : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                if bottomText != nil {
                    Text(bottomText!)
                        .font(.subheadline)
                        .foregroundColor(!isFilled ? color : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }
            }
            .frame(width: isLarge ? dimensions.width*2 : dimensions.width, height: dimensions.height)
            .background(isFilled ? color : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(!isFilled ? color : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), lineWidth: 1))
        }.buttonStyle(PlainButtonStyle())
    }
}

struct NoDiscoverablesAroundYou: View {
    var body: some View {
        VStack(alignment: .center){
            Spacer()
            Image(systemName: "mappin.slash")
                .resizable()
                .frame(width: 152, height: 205)
                .imageScale(.large)
                .font(.largeTitle)
                .foregroundColor(Color(.systemGray))
            if MapController.lastLocation != nil{
            Text("It seems there's no one to help around you")
                .font(.headline).foregroundColor(Color(.systemGray))
            }
            else{
                Text("Your location is currently unavailable")
                    .font(.headline).foregroundColor(Color(.systemGray))
                Text("Enable localization to use the discover section")
                    .font(.headline).foregroundColor(Color(.systemGray))
            }
            Spacer()
        }.offset(y: -30)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style
    let color: UIColor
    
    init(style: UIActivityIndicatorView.Style = .large, color: UIColor = .secondaryLabel) {
        self.style = style
        self.color = color
    }
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = color
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let source: UIImagePickerController.SourceType
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TOCropViewControllerDelegate {
        @Binding var image: UIImage?
        init(image: Binding<UIImage?>) {
            self._image = image
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            let cropController = TOCropViewController(croppingStyle: .default, image: selectedImage)
            cropController.delegate = self
            cropController.aspectRatioPreset = .presetSquare
            cropController.aspectRatioLockEnabled = true
            cropController.resetAspectRatioEnabled = false
            cropController.aspectRatioPickerButtonHidden = true
            picker.pushViewController(cropController, animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        public func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            self.image = image
            cropViewController.dismiss(animated: true)
        }
        public func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            cropViewController.dismiss(animated: true)
        }
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.imageExportPreset = .compatible
        picker.allowsEditing = false
        picker.view.tintColor = .systemOrange
        if source != .camera {
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.showsCameraControls = true
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}

struct SizedDivider: View {
    let width: CGFloat
    let height: CGFloat
    
    init(height: CGFloat, width: CGFloat = UIScreen.main.bounds.width) {
        self.height = height
        self.width = width
    }
    var body: some View {
        Rectangle().frame(width: width, height: height).hidden()
    }
}

struct AlertView: View{
    @Binding var isPresented: Bool
    
    var body: some View{
        VStack{
            EmptyView()
        }.alert(isPresented: $isPresented){
            Alert(title: Text("Oh no!"), message: Text("It seems that this request was already accepted by another user.\nThank you anyway for your help and support, we really apreciate it."), dismissButton: .default(Text("Got it!")))
        }
    }
}
