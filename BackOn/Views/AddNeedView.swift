import SwiftUI
import CoreLocation
import MapKit

struct AddNeedView: View {
    
    @EnvironmentObject var shared : Shared
    @ObservedObject var datePickerData = DatePickerData()
    @ObservedObject var titlePickerData = TitlePickerData()
    
    @State var toggleRepeat = false //CONTIENE INFORMAZIONI
    @State var toggleVerified = false //CONTIENE INFORMAZIONI
    
    @State var needDescription = "" //CONTIENE INFORMAZIONI
    @ObservedObject var address = Address() //address.address contiene l'address //CONTIENE INFORMAZIONI

    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    
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
                        Text(titlePickerData.titlePickerValue == -1 ? "Click to select your need\t\t\t\t\t\t\t\t\t" : titlePickerData.titles[self.titlePickerData.titlePickerValue])
                            .onTapGesture {
                                withAnimation {self.titlePickerData.showTitlePicker.toggle()}
                        }
                    }
                    HStack{Text("Description: ")
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
                        Text("\(datePickerData.selectedDate, formatter: self.shared.dateFormatter)\t\t\t\t\t\t\t")
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
                            
                            Text(self.address.address).onAppear(perform: {
                                self.shared.textAddress()
                            })
                        }
                        Toggle(isOn: $address.toggleMyActualLocation) {
                            Text("Do you want to set the location where you are right now?")
                        }
                    
//                        Manca la selezione del posto fatta bene
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
                Button(action: {
                    print("Add need!")
                    //                IMPORTANTE SALVA NEED E INVIALO AL SERVER
                    NeederHomeView.show()
                    self.dbController.insertCommit(title: self.titlePickerData.titles[self.titlePickerData.titlePickerValue], description: self.needDescription, date: self.datePickerData.selectedDate, latitude: self.shared.locationManager.lastLocation!.coordinate.latitude, longitude: self.shared.locationManager.lastLocation!.coordinate.longitude)
                    self.dbController.getCommitByUser()
                }) {
                    HStack{
                        Text("Confirm ")
                            .fontWeight(.regular)
                        Image(systemName: "hand.thumbsup")
                    }
                    .font(.title)
                    .padding(20)
                    .background(Color.blue)
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.blue, lineWidth: 1).foregroundColor(Color.blue)
                    )
                }
                Spacer()
            }
            
        } //Chiusura VStack
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .background(Color(.systemGray6))
            .overlay(myOverlay(isPresented: self.$titlePickerData.showTitlePicker, toOverlay: AnyView(TitlePicker(pickerElements: self.titlePickerData.titles, selectedValue: self.$titlePickerData.titlePickerValue))))
            .overlay(myOverlay(isPresented: self.$datePickerData.showDatePicker, toOverlay: AnyView(DataPicker(dataSelezionata: self.$datePickerData.selectedDate))))
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
    @Binding var dataSelezionata: Date
    
    var body: some View {
        VStack {
            DatePicker(selection: self.$dataSelezionata, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {
                Text("Select a date")
            }.labelsHidden()
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .background(Color.primary.colorInvert())
        }.frame(width: UIScreen.main.bounds.width, height: 250)
            .background(Color.primary.colorInvert())
    }
}

class Address: ObservableObject {
    let shared = (UIApplication.shared.delegate as! AppDelegate).shared
    @Published var address = "Insert your address\t\t\t\t\t\t\t\t\t\t\t"
    @Published var toggleMyActualLocation = false{
        willSet{
            self.address = newValue ? self.shared.addressText : self.address
            print(self.address)
        }
    }
}
