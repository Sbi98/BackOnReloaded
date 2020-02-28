import SwiftUI
import CoreLocation
import MapKit

struct AddNeedView: View {
    
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    @ObservedObject var datePickerData = DatePickerData()
    @ObservedObject var titlePickerData = TitlePickerData()
    
    @State var toggleRepeat = false //CONTIENE INFORMAZIONI
    @State var toggleVerified = false //CONTIENE INFORMAZIONI
    
    @State var needDescription = "" //CONTIENE INFORMAZIONI
    @ObservedObject var addressData = AddressData() //address.address contiene l'address //CONTIENE INFORMAZIONI

    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    
    let formatter = DateFormatter()
    var dateString: String?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Text("Add Need")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                CloseButton()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            Form{
                Section(header: Text("Need informations")){
                    HStack{
                        Text("Title: ")
                            .foregroundColor(Color(.systemBlue))
                        Text(titlePickerData.titlePickerValue == -1 ? "Click to select your need" : titlePickerData.titles[self.titlePickerData.titlePickerValue])
                            .onTapGesture {
                                withAnimation {self.titlePickerData.showTitlePicker.toggle()}
                        }
                    }
                    HStack{
                        Text("Description: ")
                            .foregroundColor(Color(.systemBlue))
                        TextField("Description", text: self.$needDescription)
                            .padding(7)
                            .frame(minHeight: 30)
                            .background(Color.primary.colorInvert())
                            .cornerRadius(5)
                            .font(.callout)
                    }
                }
                
                Section(header: Text("Time")){
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
                Section(header: Text("Location")){
                    HStack{
                        Text("Place: ")
                            .foregroundColor(Color(.systemBlue))
                        TextField("Insert your address", text: self.$addressData.address)
                            .padding(7)
                            .frame(minHeight: 30)
                            .background(Color.primary.colorInvert())
                            .font(.callout)
                    }
                    Toggle(isOn: $addressData.toggleMyActualLocation) {
                        Text("Do you want to set the location where you are right now?")
                    }
                }
                
                Section (header: Text("Need informations")){
                    Toggle(isOn: $toggleVerified) {
                        Text("Do you want only verified helpers?")
                    }
                }
            }//CHIUSURA FORM
//            ANDRÀ CAMIATA LA POSIZIONE
            Spacer()
            HStack {
                Spacer()
                ConfirmAddNeedButton(){
                    self.dbController.insertCommit(title: self.titlePickerData.titles[self.titlePickerData.titlePickerValue], description: self.needDescription, date: self.datePickerData.selectedDate, latitude: self.mapController.lastLocation!.coordinate.latitude, longitude: self.mapController.lastLocation!.coordinate.longitude)
                    self.dbController.getCommitByUser()
                }
                Spacer()
            }
            
        } //Chiusura VStack
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .background(Color(.systemGray6))
            .overlay(myOverlay(isPresented: self.$titlePickerData.showTitlePicker, toOverlay: AnyView(TitlePicker(pickerElements: self.titlePickerData.titles, selectedValue: self.$titlePickerData.titlePickerValue))))
            .overlay(myOverlay(isPresented: self.$datePickerData.showDatePicker, toOverlay: AnyView(DataPicker(selectedDate: self.$datePickerData.selectedDate))))
    }
}

class TitlePickerData: ObservableObject {
    var titles = ["Getting groceries","Shopping","Pet Caring","Houseworks","Sharing time","Wheelchair transport"]
    @Published var showTitlePicker = false
    @Published var titlePickerValue = -1
}

struct TitlePicker: View {
    var pickerElements: [String]
    @Binding var selectedValue: Int
    var body: some View {
        Picker("Select your need", selection: self.$selectedValue) {
            ForEach(0 ..< self.pickerElements.count) {
                Text(self.pickerElements[$0])
                    .font(.headline)
                    .fontWeight(.medium)
            }
        }.labelsHidden()
            .frame(width: UIScreen.main.bounds.width, height: 250)
            .background(Color.primary.colorInvert())
    }
}

class DatePickerData: ObservableObject {
    @Published var showDatePicker = false
    @Published var selectedDate = Date()
}

struct DataPicker: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            DatePicker(selection: self.$selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {
                Text("Select a date")
            }.labelsHidden()
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .background(Color.primary.colorInvert())
        }.frame(width: UIScreen.main.bounds.width, height: 250)
            .background(Color.primary.colorInvert())
    }
}

class AddressData: ObservableObject, CustomStringConvertible {
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    public var description: String {
        return self.address
    }
    @Published var address = "Insert your address"
    @Published var toggleMyActualLocation = false {
        willSet{
            self.mapController.locationAsAddress() { result in
                self.address = result
                print(result)
            }
        }
    }
}
