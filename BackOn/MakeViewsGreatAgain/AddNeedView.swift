import SwiftUI

struct AddNeedView: View {
    @EnvironmentObject var underlyingVC: ViewControllerHolder
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    @State var showTitlePicker = false
    @State var titlePickerValue = -1
    @State var requestDescription = ""
    @State var showDatePicker = false
    @State var selectedDate = Date(timeIntervalSinceReferenceDate: 0)
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
                DispatchQueue.main.async { self.underlyingVC.dismissVC() }
                MapController.addressToCoordinates(self.address) { result, error in
                    guard error == nil, let result = result else {return}
                    let splitted = self.address.split(separator: ",")
                    var city: String?
                    if splitted.count == 2 { city = "\(splitted[1])"} //+2 se riaggiungi CAP e Stato
                    if splitted.count == 3 { city = "\(splitted[2])"}
                    if city == nil { city = "Incorrect city" }
                    DatabaseController.addRequest (
                        title: Souls.categories[self.titlePickerValue],
                    let request = Request(neederID: CoreDataController.loggedUser!._id, title: self.shared.requestCategories[self.titlePickerValue], descr: self.requestDescription == "" ? nil : self.requestDescription, date: self.selectedDate, latitude: result.latitude, longitude: result.longitude, _id: "waitingForServerResponse", address: self.address, city: city)
                    DispatchQueue.main.async { request.waitingForServerResponse = true; self.shared.myRequests[request._id] = request }
                    DatabaseController.addRequest(request: request) { id, error in
                        if error == nil, let id = id {
                            DispatchQueue.main.sync {
                                self.shared.myRequests["waitingForServerResponse"] = nil
                                request.waitingForServerResponse = false
                                request._id = id
                                self.shared.myRequests[id] = request
                            }
                            CoreDataController.addBond(request)
                            let _ = CalendarController.addRequest(request: request)
                        } else {
                            DispatchQueue.main.async { request.waitingForServerResponse = false; self.shared.myRequests["waitingForServerResponse"] = nil }
                        }
                    }
                    /*DatabaseController.addRequest (
                        title: self.shared.requestCategories[self.titlePickerValue],
                        description: self.requestDescription == "" ? nil : self.requestDescription,
                        address: self.address,
                        city: city!,
                        date: self.selectedDate,
                        coordinates: result
                    ){ newRequest, error in
                        guard error == nil, let request = newRequest else {print("Error while adding the request"); return}
                        DispatchQueue.main.async { self.shared.myRequests[request._id] = request }
                        CoreDataController.addTask(task: request)
                        let _ = CalendarController.addRequest(request: request)
                    }*/
                }
            }
        }) {
            Text("Confirm").orange().bold()
        }
    }
    
    var body: some View {
        UITableView.appearance().backgroundColor = .systemGray6
        return NavigationView {
            Form {
                Section(header: Text("Need informations")) {
                    HStack {
                        Text("Title: ").orange()
                        Spacer()
                        Text(titlePickerValue == -1 ? "Click to select your need" : Souls.categories[titlePickerValue])
                            .colorIf(titleNeeded, .systemRed, titlePickerValue == -1 ? .systemGray3 : .black)
                            .onTapGesture {withAnimation{
                                self.titlePickerValue = 0
                                self.showTitlePicker.toggle()
                                self.titleNeeded = false
                                self.underlyingVC.setEditMode(true)
                            }}
                    }
                    HStack {
                        Text("Description: ").orange()
                        TextField("Insert a description (optional)", text: self.$requestDescription).multilineTextAlignment(.trailing).offset(y: 1)
                    }
                }
                if titleNeeded {Section(header: Text("You must insert a title!").colorIf(true, .systemRed)){EmptyView()}}
                Section(header: Text("Time")) {
                    HStack{
                        Text("Date: ").orange()
                        Spacer()
                        Text(selectedDate == Date(timeIntervalSinceReferenceDate: 0) ? "Click to insert a date" : "\(selectedDate, formatter: customDateFormat)")
                            .colorIf(dateNeeded, .systemRed, selectedDate == Date(timeIntervalSinceReferenceDate: 0) ? .systemGray3 : .black)
                            .onTapGesture {withAnimation{
                                self.showDatePicker.toggle()
                                self.dateNeeded = false
                                self.underlyingVC.setEditMode(true)
                            }}
                    }
                }
                Section(header: Text("Location")) {
                    HStack{
                        Text("Place: ").orange()
                        Spacer()
                        Text(self.address)
                            .colorIf(locationNeeded, .systemRed, address == "Click to insert the location" ? .systemGray3 : .black)
                            .onTapGesture {withAnimation{
                                self.showAddressCompleter = true
                                self.locationNeeded = false
                                self.underlyingVC.setEditMode(true)
                            }}
                    }
                }
            }
            .onTapGesture {UIApplication.shared.windows.first!.endEditing(true)}
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .sheet(isPresented: self.$showAddressCompleter){searchLocation(selection: self.$address)}
            .navigationBarTitle(Text("Add a need").orange(), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {self.underlyingVC.dismissVC()}){Text("Cancel").orange()}, trailing: confirmButton)
        }
        .myoverlay(isPresented: self.$showTitlePicker, toOverlay: ElementPickerGUI(pickerElements: Souls.categories, selectedValue: self.$titlePickerValue))
        .myoverlay(isPresented: self.$showDatePicker, toOverlay: DatePickerGUI(selectedDate: self.$selectedDate))
    }
}

/*
if locationNeeded {
    Image(systemName: "exclamationmark.circle.fill").foregroundColor(Color(.systemRed))
}
Toggle(isOn: $toggleRepeat) {
Text("Repeat each week at the same hour")
}
Section(header: Text("Need informations")) {
   Toggle(isOn: $toggleVerified) { Text("Do you want only verified helpers?") }
}
*/
