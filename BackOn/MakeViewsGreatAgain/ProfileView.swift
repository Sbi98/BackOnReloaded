//
//  ProfileView.swift
//  BackOn
//
//  Created by Giancarlo Sorrentino on 10/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var name = CoreDataController.loggedUser!.name
    @State var surname = CoreDataController.loggedUser!.surname ?? ""
    @State var showModal = false
    @State var showActionSheet = false
    @State var pickerMode: UIImagePickerController.SourceType = .photoLibrary
    @State var image: UIImage?
    
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Upload a profile pic"), message: Text("Choose Option"), buttons: [
            .default(Text("Take a picture")) {
                self.pickerMode = .camera
                self.showModal.toggle()
                self.showActionSheet.toggle()
            },
            .default(Text("Photo Library")) {
                self.pickerMode = .photoLibrary
                self.showModal.toggle()
                self.showActionSheet.toggle()
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
                    Button(action: {self.showActionSheet.toggle()}){
                        Avatar(image: CoreDataController.loggedUser!.profilePic, size: 150)
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
                            Text("Name: ")
                                .foregroundColor(Color(.systemOrange))
                            TextField("You haven't set a name yet", text: $name).multilineTextAlignment(.trailing).offset(y: 1)
                        }
                        HStack {
                            Text("Surname: ")
                                .foregroundColor(Color(.systemOrange))
                            TextField("You haven't set a surname yet", text: $surname).multilineTextAlignment(.trailing).offset(y: 1)
                        }
                        HStack {
                            Text("Mail: ")
                                .foregroundColor(Color(.systemOrange))
                            Spacer()
                            Text(CoreDataController.loggedUser!.email)
                        }
                    }
                }
            }
            .actionSheet(isPresented: $showActionSheet){actionSheet}
            .sheet(isPresented: $showModal) {ImagePicker(image: self.$image, source: self.pickerMode).edgesIgnoringSafeArea(.all)}
            .navigationBarTitle(Text("Your profile").foregroundColor(Color(.systemOrange)), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {self.presentationMode.wrappedValue.dismiss()})
                {Text("Cancel").foregroundColor(Color(.systemOrange))},
                trailing: Button(action: {self.presentationMode.wrappedValue.dismiss()})
                {Text("Save").foregroundColor(Color(.systemOrange))}
            )
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
