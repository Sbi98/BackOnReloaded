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
    @State var profilePic: UIImage? = CoreDataController.loggedUser!.photo
    @State var nameNeeded = false
    @State var showAlert = false
    
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
        return NavigationView {
            VStack (spacing: 0){
                HStack {
                    Spacer()
                    Button(action: {if self.underlyingVC.isEditing{self.underlyingVC.present(optionMenu)}}){
                        Image(uiImage: profilePic).avatar(size: 150)
                            .overlayIf(.constant(self.underlyingVC.isEditing), toOverlay: editPhotoOverlay, alignment: .bottom)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }.buttonStyle(PlainButtonStyle()).padding()
                    Spacer()
                }.background(Color(.systemGray6))
                Form {
                    Section(header: Text("Personal informations")) { //BISOGNA AGGIUNGERE L?ALERT COME NELLA ADD NEED SE IL NOME È VUOTO
                        HStack {
                            Text("Name: ")
                                .orange()
                            TextField("Name field is requred!", text: $name)
                                .disabled(!underlyingVC.isEditing)
                                .multilineTextAlignment(.trailing).offset(y: 1)
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
                            TextField("", text: $phoneNumber)
                                .disabled(!underlyingVC.isEditing)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing).offset(y: 1)
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
                            CoreDataController.deleteAll()
                            DispatchQueue.main.async { (UIApplication.shared.delegate as! AppDelegate).shared.mainWindow = "LoginPageView" }
                        }
                        
                    }
                }
                
            }
            .onTapGesture {self.underlyingVC.value.view.endEditing(true)}
            .navigationBarTitle(Text("Your profile").orange(), displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error while updating profile"), message: Text("Check your connection and try again later"), dismissButton: .default(Text("Got it!")))
            }
            .navigationBarItems(
                leading: Button(action: {self.underlyingVC.dismissVC()})
                {Text("Cancel").orange()},
                trailing: Button(action: {
                    self.underlyingVC.toggleEditMode()
                    //Se sono in edit mode e qualche parametro è cambiato...
                    guard !self.underlyingVC.isEditing && (self.name != CoreDataController.loggedUser!.name || self.surname != CoreDataController.loggedUser!.surname || self.profilePic != CoreDataController.loggedUser!.photo || self.phoneNumber != CoreDataController.loggedUser!.phoneNumber) else {return}
                    guard self.name != "" else {return} //alert che il nome non può essere vuoto
                    self.name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.surname = self.surname.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.phoneNumber = self.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.phoneNumber = self.phoneNumber.replacingOccurrences(of: "-", with: "")
                    let regex = try! NSRegularExpression(pattern: "[+]?[0-9]")
                    let result = regex.firstMatch(in: self.phoneNumber, options: [], range: NSRange(location: 0, length: self.phoneNumber.count))
                    guard result != nil && self.phoneNumber.count <= 15 else {print("Numero di telefono errato!"); return}
                    DatabaseController.updateProfile(
                        newName: self.name,
                        newSurname: self.surname,
                        newPhoneNumber: self.phoneNumber,
                        newImageEncoded: self.profilePic?.jpegData(compressionQuality: 0.25)?.base64EncodedString(options: .lineLength64Characters)
                    ){ responseCode, error in
                        guard error == nil else {self.showAlert = true; print("Error while updating profile"); return}
                        CoreDataController.loggedUser!.name = self.name
                        CoreDataController.loggedUser!.surname = self.surname == "" ? nil : self.surname
                        CoreDataController.loggedUser!.phoneNumber = self.phoneNumber == "" ? nil : self.phoneNumber
                        if responseCode == 200 {CoreDataController.loggedUser!.photo = self.profilePic}
                        else {self.showAlert = true} //401: Errore nel caricamento della nuova immagine, ma okay per nome/cognome
                        CoreDataController.updateLoggedUser(user: CoreDataController.loggedUser!)
                        DispatchQueue.main.async { (UIApplication.shared.delegate as! AppDelegate).shared.profileUpdated.toggle() }
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
