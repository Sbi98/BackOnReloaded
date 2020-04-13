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
    @State var showActionSheet = false
    @State var image: UIImage?
    
    @State var showingAlert = false
    
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Upload a profile pic"), message: Text("Choose Option"), buttons: [
            .default(Text("Take a picture")) {
                self.showActionSheet.toggle()
                self.underlyingVC.presentViewInChildVC(ImagePicker(image: self.$image, source: .camera).edgesIgnoringSafeArea(.all), hideStatusBar: true)
            },
            .default(Text("Photo Library")) {
                self.showActionSheet.toggle()
                self.underlyingVC.presentViewInChildVC(ImagePicker(image: self.$image, source: .photoLibrary).edgesIgnoringSafeArea(.all), hideStatusBar: true)
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
                        Avatar(image: image == nil ? CoreDataController.loggedUser!.profilePic : Image(uiImage: image!), size: 150)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 5)
                            .padding(.top)
                            .padding()
                    }.buttonStyle(PlainButtonStyle())
                    Spacer()
                }.background(Color(.systemGray6))
                Form {
                    Section(header: Text("Personal informations")) {
                        HStack {
                            Text("Name: ").orange()
                            TextField("You haven't set a name yet", text: $name)
                                .disabled(!underlyingVC.isEditing)
                                .multilineTextAlignment(.trailing).offset(y: 1)
                        }
                        HStack {
                            Text("Surname: ")
                                .orange()
                            TextField("You haven't set a surname yet", text: $surname)
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
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error while updating profile"), message: Text("Image upload or DB error"), dismissButton: .default(Text("Got it!")))
            }
            .navigationBarItems(
                leading: Button(action: {self.underlyingVC.dismissVC()})
                {Text("Cancel").orange()},
                trailing: Button(action: {
                    self.underlyingVC.toggleEditMode()
                    var base64String: String? = nil
                    if(self.image != nil){
            
                        let imageData = self.image!.jpegData(compressionQuality: 0.20)
                        base64String = imageData!.base64EncodedString(options: .lineLength64Characters)
                        //print(base64String)
                        
                    }
                    DatabaseController.updateProfile(newName: self.name, newSurname: self.surname, newImage: base64String){ responseCode, error in
                        guard error == nil, let resCode = responseCode else {print("Error while updating profile"); return}
                        
                        if resCode == 200 {
                            CoreDataController.updateUser(image: self.image,name:  self.name,surname:  self.surname)
                        } else if resCode == 401 {
                            CoreDataController.updateUser(name:  self.name,surname:  self.surname)
                            self.showingAlert=true
                        } else {
                            self.showingAlert=true
                        }
                        
                    }
                    
                    
                }) {if underlyingVC.isEditing {Text("Done").bold().orange()} else {Text("Edit").orange()}}
            )
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
