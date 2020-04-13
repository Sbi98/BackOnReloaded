//
//  Extensions.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 13/04/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit


extension View {
    var darkMode: Bool {
        get {
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark
        }
    }
    func myoverlay<Content:View>(isPresented: Binding<Bool>, toOverlay: Content) -> some View {
        return self.overlay(myOverlay(isPresented: isPresented, toOverlay: AnyView(toOverlay)))
    }
    static func show() {
        (UIApplication.shared.delegate as! AppDelegate).shared.activeView = String(describing: self)
    }
    static func isActive() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).shared.activeView == String(describing: self)
    }
    static func isMainWindow() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).shared.mainWindow == String(describing: self)
    }
}

extension Text {
    func orange() -> Text {
        return self.foregroundColor(Color(.systemOrange))
    }
    func colorIf(_ apply: Bool, _ color: UIColor, _ otherwise: UIColor = .systemOrange) -> Text {
        return apply ? self.foregroundColor(Color(color)) : self.foregroundColor(Color(otherwise))
    }
    static func ofEditButton(_ editMode: Bool) -> Text {
        return editMode ? Text("Done").orange().bold() : Text("Edit").orange()
    }
    
}


extension Image {
    init(uiImage: UIImage?) {
        if uiImage == nil {
            self.init("NobodyIcon")
        } else {
            self.init(uiImage: uiImage!)
            self = self.renderingMode(.original)
        }
    }
    func avatar(size: CGFloat = 50) -> some View {
        return self
            .resizable()
            .orange()
            .scaledToFit()
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
    }
    func orange() -> some View {
        return self.foregroundColor(Color(.systemOrange))
    }
}

