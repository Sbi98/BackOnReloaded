import SwiftUI

struct AddNeedView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var nestedPresentationMode: Binding<PresentationMode>?
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    @State var showTitlePicker = false
    @State var titlePickerValue = -1
    @State var requestDescription = ""
    @State var showDatePicker = false
    @State var selectedDate = Date()
    @State var toggleRepeat = false
    @State var address = "Click to insert the location"
    @State var showAddressCompleter = false
    @State var toggleVerified = false
    @State var locationNeeded = false
    @State var titleNeeded = false
    @State var dateNeeded = false

    var confirmButton: some View {
        Button(action: {
            self.locationNeeded = self.address == "Click to insert the location"
            self.titleNeeded = self.titlePickerValue == -1
            self.dateNeeded = self.selectedDate < Date()
            if !(self.locationNeeded || self.titleNeeded || self.dateNeeded) {
                DispatchQueue.main.async {
                    self.nestedPresentationMode?.wrappedValue.dismiss()
                    self.presentationMode.wrappedValue.dismiss()
                }
                MapController.addressToCoordinates(self.address) { result, error in
                    guard error == nil, let result = result else {return}
                    let splitted = self.address.split(separator: ",")
                    var city: String?
                    if splitted.count == 2 { city = "\(splitted[1])"} //+2 se riaggiungi CAP e Stato
                    if splitted.count == 3 { city = "\(splitted[2])"}
                    if city == nil { city = "Incorrect city" }
                    DatabaseController.addRequest (
                        title: self.shared.requestCategories[self.titlePickerValue],
                        description: self.requestDescription == "" ? nil : self.requestDescription,
                        address: self.address,
                        city: city!,
                        date: self.selectedDate, coordinates: result
                    ){ newRequest, error in
                        guard error == nil, let request = newRequest else {print("Error while adding the request"); return}
                        DispatchQueue.main.async { self.shared.myRequests[request._id] = request }
                        CoreDataController.addTask(task: request)
                        let _ = CalendarController.addRequest(request: request)
                    }
                }
            }
        }) {
            Text("Confirm").foregroundColor(Color(.systemOrange)).bold()
        }
    }
    
    var body: some View {
        UITableView.appearance().backgroundColor = .systemGray6
        return NavigationView {
            Form {
                Section(header: Text("Need informations")) {
                    HStack {
                        Text("Title: ")
                            .foregroundColor(Color(.systemOrange))
                        Text(titlePickerValue == -1 ? "Click to select your need" : self.shared.requestCategories[titlePickerValue])
                            .onTapGesture {self.titlePickerValue = 0; withAnimation{self.showTitlePicker.toggle()}; self.titleNeeded = false}
                        if titleNeeded {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(Color(.systemRed))
                        }
                    }
                    HStack {
                        Text("Description: ")
                            .foregroundColor(Color(.systemOrange))
                        TextField("Insert a description (optional)", text: self.$requestDescription).offset(y: 1)
                    }
                }
                Section(header: Text("Time")) {
                    HStack{
                        Text("Date: ")
                            .foregroundColor(Color(.systemOrange))
                        Text("\(selectedDate, formatter: customDateFormat)")
                            .onTapGesture{withAnimation{self.showDatePicker.toggle(); self.dateNeeded = false}}
                        if dateNeeded {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(Color(.systemRed))
                        }
                    }
                    /*
                     Toggle(isOn: $toggleRepeat) {
                     Text("Repeat each week at the same hour")
                     }
                     */
                }
                Section(header: Text("Location")) {
                    HStack{
                        Text("Place: ").foregroundColor(Color(.systemOrange))
                        Text(self.address).onTapGesture{self.showAddressCompleter = true;  self.locationNeeded = false}
                        if locationNeeded {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(Color(.systemRed))
                        }
                    }
                }
                /*
                 Section(header: Text("Need informations")) {
                 Toggle(isOn: $toggleVerified) {
                 Text("Do you want only verified helpers?")
                 }
                 }
                 */
            }
            .onTapGesture {UIApplication.shared.windows.first!.endEditing(true)}
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .myoverlay(isPresented: self.$showTitlePicker, toOverlay: ElementPickerGUI(pickerElements: self.shared.requestCategories, selectedValue: self.$titlePickerValue))
            .myoverlay(isPresented: self.$showDatePicker, toOverlay: DatePickerGUI(selectedDate: self.$selectedDate))
            .sheet(isPresented: self.$showAddressCompleter){searchLocation(selection: self.$address)}
            .navigationBarTitle(Text("Add a need").foregroundColor(Color(.systemOrange)), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {self.presentationMode.wrappedValue.dismiss()}){Text("Cancel").foregroundColor(Color(.systemOrange))}, trailing: confirmButton)
        }
    }
}

