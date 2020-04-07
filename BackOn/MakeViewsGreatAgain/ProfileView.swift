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
    var body: some View {
        UITableView.appearance().backgroundColor = .systemGray6
        return NavigationView {
            VStack (spacing: 0){
                HStack {
                    Spacer()
                    Avatar(image: CoreDataController.loggedUser!.profilePic, size: 150)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 5)
                        .padding(.top)
                        .padding()
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
