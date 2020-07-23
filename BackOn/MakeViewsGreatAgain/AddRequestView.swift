import SwiftUI

struct AddRequestView: View {
    @EnvironmentObject var underlyingVC: ViewControllerHolder
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    
    @State var showTitlePicker = false
    @State var titlePickerValue = -1
    @State var requestDescription = ""
    @State var showDatePicker = false
    @State var selectedDate = Date(timeIntervalSinceReferenceDate: 0)
    @State var address = "Click to insert the location"
    @State var showAddressCompleter = false
    
    @State var locationNeeded = false
    @State var titleNeeded = false
    @State var descriptionNeeded = false
    @State var dateNeeded = false
    private var toAppendDescription: String{
        get{
        return titlePickerValue != -1 && Souls.categories[titlePickerValue] == "Other..." ? "(required)" : "(optional)"
        }
    }
    
    private func addRequest(request: Request){
        DatabaseController.addRequest(request: request) { id, error in
           if error == nil, let id = id {
               DispatchQueue.main.sync {
                request._id = id
                request.waitingForServerResponse = false
                self.shared.myRequests["waitingForServerResponse"] = nil
                self.shared.myRequests[id] = request
               }
               CoreDataController.addBond(request)
               let _ = CalendarController.addRequest(request: request)
           } else {
               DispatchQueue.main.async {
                   let alert = UIAlertController(title: "Oh no!", message: "It seems we had a problem adding your request.\nDo you want to try again?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
                    request.waitingForServerResponse = false
                    self.shared.myRequests["waitingForServerResponse"] = nil
                }))
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    self.addRequest(request: request)
                }))
                   UIViewController.main?.present( alert, animated: true)
                   
               }
           }
       }
    }
    
    //    @State var toggleVerified = false
    //    @State var toggleRepeat = false
    
    private let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
    @State var busy = false
    
    var confirmButton: some View {
        Button(action: {
            self.locationNeeded = self.address == "Click to insert the location"
            self.titleNeeded = self.titlePickerValue == -1
            self.descriptionNeeded = self.titlePickerValue != -1 && Souls.categories[self.titlePickerValue] == "Other..." && self.requestDescription == ""
            self.dateNeeded = self.selectedDate < Date()
            if !(self.locationNeeded || self.titleNeeded || self.dateNeeded || self.descriptionNeeded) {
                DispatchQueue.main.async { self.underlyingVC.dismissVC() }
                MapController.addressToCoordinates(self.address) { result, error in
                    guard error == nil, let result = result else {print("Error while getting the coordinates. Can't add the need!");return}
                    let splitted = self.address.split(separator: ",")
                    var city: String?
                    if splitted.count == 2 { city = "\(splitted[1])"} //+2 se riaggiungi CAP e Stato
                    if splitted.count == 3 { city = "\(splitted[2])"}
                    if city == nil { city = "Incorrect city" }
                    let request = Request(neederID: CoreDataController.loggedUser!._id, title: Souls.categories[self.titlePickerValue], descr: self.requestDescription == "" ? nil : self.requestDescription, date: self.selectedDate, latitude: result.latitude, longitude: result.longitude, _id: "waitingForServerResponse", address: self.address, city: city)
                    DispatchQueue.main.async { request.waitingForServerResponse = true; self.shared.myRequests[request._id] = request }
                    self.addRequest(request: request)
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
//        let dateBinding: Binding<Date> = Binding(
//            get: {self.selectedDate},
//            set: { newDate in
//                self.selectedDate = newDate
//                self.busy = (self.selectedDate != self.referenceDate && CalendarController.isBusy(when: newDate))
//                self.showCallout = false
//            }
//        )
        return NavigationView {
            Form {
                Section(header: Text("Need information")) {
                    HStack {
                        Text("Title: ").orange()
                        Spacer()
                        Text(titlePickerValue == -1 ? "Click to select your need" : Souls.categories[titlePickerValue])
                            .tintIf(titleNeeded, .red, titlePickerValue == -1 ? .gray3 : .primary)
                            .onTapGesture {withAnimation{
                                self.titlePickerValue = self.titlePickerValue == -1 ? 0 : self.titlePickerValue
                                self.showTitlePicker.toggle()
                                self.titleNeeded = false
                                self.underlyingVC.setEditMode(true)
                                }}
                    }
                    HStack {
                        Text("Description: ").orange()
                        SuperTextField(
                            placeholder: Text( "Insert a description " + toAppendDescription),
                            text: self.$requestDescription, required: self.$descriptionNeeded)
                    }
                }
                Section(header: Text("Time")) {
                    VStack {
//                        if busy {Spacer().animation(.easeIn(duration: 10000))}
                        HStack {
                            Text("Date: ").orange()
                            Spacer()
                            if busy {Image(systemName: "exclamationmark.triangle").tint(.yellow).onTapGesture{withAnimation{self.showDatePicker.toggle()}}}
                            Text(selectedDate == referenceDate ? "Click to insert a date" : "\(selectedDate, formatter: customDateFormat)")
                                .tintIf(dateNeeded, .red, selectedDate == referenceDate ? .gray3 : .primary)
                                .onTapGesture {withAnimation{
                                    self.showDatePicker.toggle()
                                    self.dateNeeded = false
                                    self.underlyingVC.setEditMode(true)
                                }}
                        }
//                        if busy {
//                            Group {
//                                HStack{ Spacer(); Text("You seem busy at that time").font(.caption).tint(.yellow)}
//                                Spacer()
//                            }.animation(.easeIn(duration: 10000))
//                        }
                    }
                }
                Section(header: Text("Location")) {
                    HStack{
                        Text("Place: ").orange()
                        Spacer()
                        Text(self.address)
                            .tintIf(locationNeeded, .red, address == "Click to insert the location" ? .gray3 : .primary)
                            .onTapGesture {withAnimation{
                                self.showAddressCompleter = true
                                self.locationNeeded = false
                                self.underlyingVC.setEditMode(true)
                            }}
                    }
                }
            }
            .onTapGesture {self.underlyingVC.value.view.endEditing(true)}
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .sheet(isPresented: self.$showAddressCompleter){searchLocation(selection: self.$address)}
            .navigationBarTitle(Text("Add a request").orange(), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {self.underlyingVC.dismissVC()}){Text("Cancel").orange()}, trailing: confirmButton)
        }
        .myoverlay(isPresented: self.$showTitlePicker, toOverlay: ElementPickerGUI(pickerElements: Souls.categories, selectedValue: self.$titlePickerValue))
        .myoverlay(isPresented: self.$showDatePicker, toOverlay: DatePickerGUI(selectedDate: self.$selectedDate, showBusyWarning: self.$busy))
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

struct SuperTextField: View {
    
    var placeholder: Text
    @Binding var text: String
    @Binding var required: Bool
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if text.isEmpty{ placeholder.tintIf(required, .red, .gray3) }
            TextField("", text: $text).multilineTextAlignment(.trailing).offset(y: 1).onTapGesture {
                self.required = false
            }
        }
    }
}
