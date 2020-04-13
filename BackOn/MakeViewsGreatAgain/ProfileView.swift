//
//  ProfileView.swift
//  BackOn
//
//  Created by Giancarlo Sorrentino on 10/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import SwiftUI
import GoogleSignIn

struct ProfileView: View {
    @EnvironmentObject var underlyingVC: ViewControllerHolder
    @State var name = CoreDataController.loggedUser!.name
    @State var surname = CoreDataController.loggedUser!.surname ?? ""
    @State var profilePic: UIImage? = CoreDataController.loggedUser!.photo
    @State var nameNeeded = false
    @State var showActionSheet = false
    @State var showAlert = false
    
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Upload a profile pic"), message: Text("Choose Option"), buttons: [
            .default(Text("Take a picture")) {
                self.showActionSheet.toggle()
                self.underlyingVC.presentViewInChildVC(ImagePicker(image: self.$profilePic, source: .camera).edgesIgnoringSafeArea(.all), hideStatusBar: true)
            },
            .default(Text("Photo Library")) {
                self.showActionSheet.toggle()
                self.underlyingVC.presentViewInChildVC(ImagePicker(image: self.$profilePic, source: .photoLibrary).edgesIgnoringSafeArea(.all), hideStatusBar: true)
            },
            .destructive(Text("Cancel"))
        ])
    }
    
    var body: some View {
        UITableView.appearance().backgroundColor = .systemGray6
        return NavigationView {
            VStack (spacing: 0){
                HStack {
                    Spacer()
                    Button(action: {if self.underlyingVC.isEditing{self.showActionSheet.toggle()}}){
                        Image(uiImage: profilePic).avatar(size: 150)
                        }.buttonStyle(PlainButtonStyle()).padding()
                    Spacer()
                }.background(Color(.systemGray6))
                Form {
                    Section(header: Text("Personal informations")) {
                        HStack {
                            Text("Name: ").orange()
                            TextField("Name field is requred!", text: $name)
                                .disabled(!underlyingVC.isEditing)
                                .multilineTextAlignment(.trailing).offset(y: 1)
                            if name == "Name field is required" {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(Color(.systemRed))
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
                            Text("Mail: ").orange()
                            Spacer()
                            Text(CoreDataController.loggedUser!.email)
                        }
                    }
                    
                    Section(header: EmptyView()) {
                        HStack {
                            Button(action: {
                                print("Logging out from Google!")
                                GIDSignIn.sharedInstance()?.disconnect()
                            }) {
                                Text("Logout").orange()
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
            .onTapGesture {UIApplication.shared.windows.first!.endEditing(true)}
            .actionSheet(isPresented: $showActionSheet){actionSheet}
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
                    guard !self.underlyingVC.isEditing && (self.name != CoreDataController.loggedUser!.name || self.surname != CoreDataController.loggedUser!.surname || self.profilePic != CoreDataController.loggedUser!.photo) else {return}
                    guard self.name != "" else {return} //alert che il nome non può essere vuoto
                    DatabaseController.updateProfile(
                        newName: self.name,
                        newSurname: self.surname,
                        newImageEncoded: self.profilePic?.jpegData(compressionQuality: 0.20)?.base64EncodedString(options: .lineLength64Characters)
                    ){ responseCode, error in
                        guard error == nil else {print("Error while updating profile"); return}
                        //401: Errore nel caricamento della nuova immagine, ma okay per nome/cognome
                        CoreDataController.loggedUser!.name = self.name
                        CoreDataController.loggedUser!.surname = self.surname == "" ? nil : self.surname
                        if responseCode != 200 {self.showAlert = true} //Errore nel caricamento dell'immagine o altri errori vari
                        else {CoreDataController.loggedUser!.photo = self.profilePic}
                    }
                }) { Text.ofEditButton(underlyingVC.isEditing) }
            )
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
