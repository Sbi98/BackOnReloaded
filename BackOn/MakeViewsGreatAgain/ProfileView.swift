//
//  ProfileView.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 10/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI
import GoogleSignIn



struct ProfileView: View {
    @EnvironmentObject var underlyingVC: ViewControllerHolder
    @State var name = CoreDataController.loggedUser!.name
    @State var surname = CoreDataController.loggedUser!.surname ?? ""
    @State var phoneNumber = CoreDataController.loggedUser!.phoneNumber ?? ""
    @State var profilePic = CoreDataController.loggedUser!.photo
    @State var nameNeeded = false
    @State var alertUpdateFailed = false
    @State var alertPhotoUploadFailed = false
    @State var alertWrongPNFormat = false
    @State var alertEmptyName = false
    
    //per ora mai usata. decidi
    private func revertChanges() {
        self.name = CoreDataController.loggedUser!.name
        self.surname = CoreDataController.loggedUser!.surname ?? ""
        self.phoneNumber = CoreDataController.loggedUser!.phoneNumber ?? ""
        self.profilePic = CoreDataController.loggedUser!.photo
    }
    
    var body: some View {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        optionMenu.view.tintColor = .systemOrange
        let camera = UIAlertAction(title: "Take a picture", style: .default, handler: {_ in
            self.underlyingVC.presentViewInChildVC(ImagePicker(image: self.$profilePic, source: .camera).edgesIgnoringSafeArea(.all), hideStatusBar: true)
        })
        let photoLibrary = UIAlertAction(title: "Choose from library", style: .default, handler: {_ in
            self.underlyingVC.presentViewInChildVC(ImagePicker(image: self.$profilePic, source: .photoLibrary).edgesIgnoringSafeArea(.all), hideStatusBar: true)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        cancel.setValue(UIColor.systemRed, forKey: "titleTextColor")
        optionMenu.addAction(camera)
        optionMenu.addAction(photoLibrary)
        optionMenu.addAction(cancel)
        let editPhotoOverlay = Text("Edit").font(.subheadline).frame(width: 150, height: 30).tint(.white).background(Color.black.opacity(0.7))
        UITableView.appearance().backgroundColor = .systemGray6
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .systemOrange
        return NavigationView {
            VStack (spacing: 0){
                HStack {
                    Spacer()
                    Button(action: {if self.underlyingVC.isEditing{self.underlyingVC.present(optionMenu)}}){
                        Image(uiImage: profilePic).avatar(size: 150)
                            .overlayIf(.constant(self.underlyingVC.isEditing), toOverlay: editPhotoOverlay, alignment: .bottom)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .alert(isPresented: $alertPhotoUploadFailed) {
                                Alert(title: Text("Error while uploading profile pic"), message: Text("Check your connection and try again later"), dismissButton: .default(Text("Got it!").orange()))
                            }
                    }.buttonStyle(PlainButtonStyle()).padding()
                    Spacer()
                }.background(Color(.systemGray6))
                Form {
                    Section(header: Text("Personal information")) {
                        HStack {
                            Text("Name: ")
                                .orange()
                            TextField("Name field is requred!", text: $name)
                                .disabled(!underlyingVC.isEditing)
                                .multilineTextAlignment(.trailing).offset(y: 1)
                                .alert(isPresented: $alertEmptyName) {
                                    Alert(title: Text("The name field must not be empty"), message: Text("Insert a valid name"), dismissButton: .default(Text("Got it!")))
                                }
                        }
                        HStack {
                            Text("Surname: ")
                                .orange()
                            TextField("", text: $surname)
                                .disabled(!underlyingVC.isEditing)
                                .multilineTextAlignment(.trailing).offset(y: 1)
                        }
                        HStack {
                            Text("Phone: ")
                                .orange()
                            TextField("Type your prefix and phone number", text: $phoneNumber)
                                .disabled(!underlyingVC.isEditing)
                                .keyboardType(.phonePad)
                                .multilineTextAlignment(.trailing).offset(y: 1)
                                .alert(isPresented: $alertWrongPNFormat) {
                                    Alert(title: Text("Wrong format for the phone number"), message: Text("The phone number should have the prefix followed by the phone number itself (e.g. +39 0123456789)"), dismissButton: .default(Text("Got it!")))
                                }
                        }
                        HStack {
                            Text("Mail: ").orange()
                            Spacer()
                            Text(CoreDataController.loggedUser!.email)
                        }
                    }
                    HStack {
                        Text("Logout").orange()
                        Spacer()
                        Image(systemName: "chevron.right").tint(.primary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.underlyingVC.dismissVC()
                        print("Logging out from Google!")
                        DatabaseController.logout(){ error in
                            guard error == nil else {print(error!); return}
                            GIDSignIn.sharedInstance()?.disconnect()
                            DispatchQueue.main.async{
                                let shared = (UIApplication.shared.delegate as! AppDelegate).shared
                                CoreDataController.deleteAll()
                                shared.mainWindow = "LoginPageView"
                                shared.deleteAll()
                            }
                        }
                        
                    }
                }
                
            }
            .onTapGesture {self.underlyingVC.value.view.endEditing(true)}
            .navigationBarTitle(Text("Your profile").orange(), displayMode: .inline)
            .alert(isPresented: $alertUpdateFailed) {
                Alert(title: Text("Error while updating profile"), message: Text("Check your connection and try again later"), dismissButton: .default(Text("Got it!")))
            }
            .navigationBarItems(
                leading: Button(action: {self.underlyingVC.dismissVC()})
                {Text("Cancel").orange()},
                trailing: Button(action: {
                    if !self.underlyingVC.isEditing {
                        self.underlyingVC.toggleEditMode()
                    } else {
                        //Se sono in edit mode e qualche parametro è cambiato...
                        guard (self.name != CoreDataController.loggedUser!.name || self.surname != CoreDataController.loggedUser!.surname || self.profilePic != CoreDataController.loggedUser!.photo || self.phoneNumber != CoreDataController.loggedUser!.phoneNumber) else {self.underlyingVC.toggleEditMode(); return}
                        self.name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        self.surname = self.surname.trimmingCharacters(in: .whitespacesAndNewlines)
                        self.phoneNumber = self.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard self.name != "" else {self.alertEmptyName = true; print("Name field must not be empty"); return}
                        if self.phoneNumber != "" {
                            let regex = try! NSRegularExpression(pattern: "(\\+\\d{2}\\s*)?(\\s*(\\d{7,15}))")
                            let result = regex.firstMatch(in: self.phoneNumber, options: [], range: NSRange(location: 0, length: self.phoneNumber.count))
                            guard result != nil && self.phoneNumber.count <= 15 else {self.alertWrongPNFormat = true; print("Wrong format for phone number"); return}
                        }
                        self.underlyingVC.toggleEditMode()
                        DatabaseController.updateProfile(
                            newName: self.name,
                            newSurname: self.surname,
                            newPhoneNumber: self.phoneNumber,
                            newImageEncoded: self.profilePic != CoreDataController.loggedUser!.photo ? self.profilePic?.jpegData(compressionQuality: 0.25)?.base64EncodedString(options: .lineLength64Characters) : nil
                        ){ responseCode, error in
                            guard error == nil else {self.alertUpdateFailed = true; print("Error while updating profile"); self.revertChanges(); return}
                            CoreDataController.loggedUser!.name = self.name
                            CoreDataController.loggedUser!.surname = self.surname == "" ? nil : self.surname
                            CoreDataController.loggedUser!.phoneNumber = self.phoneNumber == "" ? nil : self.phoneNumber
                            if responseCode == 200 {CoreDataController.loggedUser!.photo = self.profilePic}
                            else {self.alertPhotoUploadFailed = true; self.profilePic = CoreDataController.loggedUser!.photo} //401: Errore nel caricamento della nuova immagine, ma okay per nome/cognome
                            CoreDataController.updateLoggedUser(user: CoreDataController.loggedUser!)
                            DispatchQueue.main.async { (UIApplication.shared.delegate as! AppDelegate).shared.profileUpdated.toggle() }
                        }
                    }
                })
                {Text.ofEditButton(underlyingVC.isEditing)}
            )
        }//.actionSheet(isPresented: $showActionSheet){actionSheet}
    }
}

//    @State var showActionSheet = false
//    var actionSheet: ActionSheet {
//        ActionSheet(title: Text("Upload a profile pic"), message: Text("Choose Option"), buttons: [
//            .default(Text("Take a picture").orange()) {
//                self.showActionSheet.toggle()
//                self.underlyingVC.presentViewInChildVC(ImagePicker(image: self.$profilePic, source: .camera).edgesIgnoringSafeArea(.all), hideStatusBar: true)
//            },
//            .default(Text("Photo Library").orange()) {
//                self.showActionSheet.toggle()
//                self.underlyingVC.presentViewInChildVC(ImagePicker(image: self.$profilePic, source: .photoLibrary).edgesIgnoringSafeArea(.all), hideStatusBar: true)
//            },
//            .destructive(Text("Cancel"))
//        ])
//    }
