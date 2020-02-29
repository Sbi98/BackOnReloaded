import SwiftUI
import CoreLocation
import MapKit

struct AddNeedView: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    @ObservedObject var datePickerData = DatePickerData()
    @ObservedObject var titlePickerData = TitlePickerData()
    @State var toggleRepeat = false
    @State var toggleVerified = false
    @State var needDescription = ""
    @ObservedObject var addressData = AddressData()
    
    let formatter = DateFormatter()
    var dateString: String?
    
    var body: some View {
        Form {
            Section(header: HStack {
                Text("Add Need")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                CloseButton()
            }){EmptyView()}
            Section(header: Text("Need informations")) {
                HStack {
                    Text("Title: ")
                        .foregroundColor(Color(.systemBlue))
                    Text(titlePickerData.titlePickerValue == -1 ? "Click to select your need" : titlePickerData.titles[self.titlePickerData.titlePickerValue])
                        .onTapGesture {
                            withAnimation {self.titlePickerData.showTitlePicker.toggle()}
                    }
                }
                HStack {
                    Text("Description: ")
                        .foregroundColor(Color(.systemBlue))
                    TextField("Insert a description (optional)", text: self.$needDescription).offset(y: 1)
                }
            }
            Section(header: Text("Time")) {
                HStack{
                    Text("Date: ")
                        .foregroundColor(Color(.systemBlue))
                    Text("\(datePickerData.selectedDate, formatter: customDateFormat)")
                        .onTapGesture {
                            withAnimation {self.datePickerData.showDatePicker.toggle()}
                    }
                }
                Toggle(isOn: $toggleRepeat) {
                    Text("Repeat each week at the same hour")
                }
            }
            Section(header: Text("Location")) {
                HStack{
                    Text("Place: ")
                        .foregroundColor(Color(.systemBlue))
                    TextField("Insert your address", text: self.$addressData.address).offset(y: 1)
                }
                Toggle(isOn: $addressData.toggleMyActualLocation) {
                    Text("Do you want to set the location where you are right now?")
                }
            }
            Section(header: Text("Need informations")) {
                Toggle(isOn: $toggleVerified) {
                    Text("Do you want only verified helpers?")
                }
            }
            Section(header:
                HStack {
                    Spacer()
                    ConfirmAddNeedButton(){
                        self.dbController.insertCommit(title: self.titlePickerData.titles[self.titlePickerData.titlePickerValue], description: self.needDescription, date: self.datePickerData.selectedDate, latitude: self.mapController.lastLocation!.coordinate.latitude, longitude: self.mapController.lastLocation!.coordinate.longitude)
                        self.dbController.getCommitByUser()
                    }
                    Spacer()
                }
            ){EmptyView()}
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .background(Color(.blue))
        .overlay(myOverlay(isPresented: self.$titlePickerData.showTitlePicker, toOverlay: AnyView(ElementPickerGUI(pickerElements: self.titlePickerData.titles, selectedValue: self.$titlePickerData.titlePickerValue))))
        .overlay(myOverlay(isPresented: self.$datePickerData.showDatePicker, toOverlay: AnyView(DatePickerGUI(selectedDate: self.$datePickerData.selectedDate))))
    }
}

class TitlePickerData: ObservableObject {
    var titles = ["Getting groceries","Shopping","Pet Caring","Houseworks","Sharing time","Wheelchair transport"]
    @Published var showTitlePicker = false
    @Published var titlePickerValue = -1
}

class DatePickerData: ObservableObject {
    @Published var showDatePicker = false
    @Published var selectedDate = Date()
}

class AddressData: ObservableObject, CustomStringConvertible {
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    public var description: String {
        return self.address
    }
    @Published var address = "Insert your address"
    @Published var toggleMyActualLocation = false {
        willSet {
            self.mapController.locationAsAddress() { result in
                self.address = result
            }
        }
    }
}
