//
//  SharedResources.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 14/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

class Shared: ObservableObject {
    @Published var loading: Bool = false {
        didSet {
            if oldValue == false && loading == true {
                LoadingPageView.show()
                if helperMode{
                    discoverSet = [:]
                    commitmentSet = [:]
                    (UIApplication.shared.delegate as! AppDelegate).dbController.loadCommitByOther()
                    (UIApplication.shared.delegate as! AppDelegate).dbController.loadMyCommitments()
                }
                else{
                    needSet.removeAll(keepingCapacity: false)
                    (UIApplication.shared.delegate as! AppDelegate).dbController.getCommitByUser()
                }
                self.loading = false
            }
        }
    }
    @Published var previousView = "HomeView"
    @Published var authentication = false
    @Published var viewToShow = "HomeView"
    @Published var selectedCommitment = Commitment()
    @Published var commitmentSet: [Int:Commitment] = [:]
    @Published var discoverSet: [Int:Commitment] = [:]
    @Published var needSet: [Int:Commitment] = [:]
    @Published var helperMode = true

    
    private static var formatter = DateFormatter()
    var dateFormatter: DateFormatter{
        get{
            Shared.formatter.dateFormat = "MMM dd, yyyy  HH:mm"
            return Shared.formatter
        }
    }
    @Published var neederInfo: UserInfo?
//    @Published var image: URL? = URL(string: "")
    
    var darkMode: Bool{
        get{
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark
        }
    }
    
    func commitmentArray() -> [Commitment] {
        return Array(commitmentSet.values)
    }
    
    func needArray() -> [Commitment] {
        return Array(needSet.values)
    }
    
    func discoverArray() -> [Commitment] {
        return Array(discoverSet.values)
    }
    
    private func address(_ p: CLPlacemark) -> String {
        var ret = ""
        if let n = p.name, let t = p.thoroughfare, n.contains(t) {
            ret = "\(n), "
        } else {
            if let n = p.name {
                ret = "\(n), "
            }
            if let t = p.thoroughfare {
                if let st = p.subThoroughfare {
                    ret = "\(ret)\(st) "
                }
                ret = "\(ret)\(t), "
            }
        }
        if let c = p.country {
            if let aa = p.administrativeArea {
                if let l = p.locality {
                    ret = "\(ret)\(l) "
                }
                ret = "\(ret)\(aa), "
            }
            ret = "\(ret)\(c)"
        }
        if let pc = p.postalCode {
            ret = "\(ret) - \(pc)"
        }
        return ret
    }
}
