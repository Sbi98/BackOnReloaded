import SwiftUI

struct AddNeedView: View {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    let mapController = (UIApplication.shared.delegate as! AppDelegate).mapController
    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    
    var titles = ["Getting groceries","Shopping","Pet Caring","Houseworks","Sharing time","Wheelchair transport"]
    @State var showTitlePicker = false
    @State var selectedTitle = "Click to select your need"
    @State var titlePickerValue = -1 {
        didSet {
            selectedTitle = titles[titlePickerValue]
        }
    }
    @State var needDescription = ""
    @State var showDatePicker = false
    @State var selectedDate = Date()
    @State var toggleRepeat = false
    @State var address = "Click to insert the location"
    @State var showAddressCompleter = false
    @State var toggleVerified = false
    
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
                    Text(titlePickerValue == -1 ? "Click to select your need" : selectedTitle)
                        .onTapGesture {
                            self.titlePickerValue = 0
                            withAnimation{self.showTitlePicker.toggle()}
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
                    Text("\(selectedDate, formatter: customDateFormat)")
                        .onTapGesture{withAnimation{self.showDatePicker.toggle()}}
                }
                Toggle(isOn: $toggleRepeat) {
                    Text("Repeat each week at the same hour")
                }
            }
            Section(header: Text("Location")) {
                HStack{
                    Text("Place: ").foregroundColor(Color(.systemBlue))
                    Text(self.address).onTapGesture{self.showAddressCompleter = true}
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
                        self.mapController.addressToCoordinates(address: self.address) { result in
                            self.dbController.insertCommit(title: self.selectedTitle, description: self.needDescription, date: self.selectedDate, latitude: result.latitude, longitude: result.longitude)
                            self.dbController.getCommitByUser()
                        }
                    }
                    Spacer()
                }
            ){EmptyView()}
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .background(Color(.blue))
        .overlay(myOverlay(isPresented: self.$showTitlePicker, toOverlay: AnyView(ElementPickerGUI(pickerElements: self.titles, selectedValue: self.$titlePickerValue))))
        .overlay(myOverlay(isPresented: self.$showDatePicker, toOverlay: AnyView(DatePickerGUI(selectedDate: self.$selectedDate))))
        .sheet(isPresented: self.$showAddressCompleter){searchLocation(selection: self.$address)}
    }
}

