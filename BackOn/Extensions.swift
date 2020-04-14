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
    func myoverlay<Content:View>(isPresented: Binding<Bool>, toOverlay: Content) -> some View {
        return self.overlay(myOverlay(isPresented: isPresented, toOverlay: toOverlay))
    }
    func loadingOverlay(isPresented: Binding<Bool>, opacity: Double = 0.6) -> some View {
        return self.overlay(myOverlay(isPresented: isPresented, toOverlay: ActivityIndicator(color: .white), alignment: .center, opacity: opacity))
    }
    func blackOverlayIf(_ show: Binding<Bool>, opacity: Double = 0.6) -> some View {
        return self.overlay(myOverlay(isPresented: show, toOverlay: EmptyView(), alignment: .center, opacity: opacity))
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

enum Palette {
    case orange
    case black
    case gray
    case system
}

/*
 GUIDA AI COLORI
 - aggiungere alla palette i nomi dei colori
 - aggiungere i case corrispondenti nella funzione tint
 - applicare tint agli elementi desiderati
 
 N.B. i Color(.system^^^^^) si adattano automaticamente ai cambi lighht/dark mode e viceversa
 (e le coppie di colori utilizzati sono studiate da Apple. Le potete vedere a questo link: https://www.avanderlee.com/wp-content/uploads/2019/02/SemanticUI_app_Aaron_Brethorst.png)
 
 Se usate colori non .system^^^^^ e che devono cambiare a seconda della modalità nella vista in cui chiamate la .tint aggiungete
 @Environment(.\colorScheme) var colorScheme
 */
extension View {
    func tint(_ color: Palette) -> some View {
        switch color {
        case .orange:
            return self.foregroundColor(Color(.systemOrange))
        case .black: //SOLO DI TEST
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? self.foregroundColor(.green) : self.foregroundColor(.red)
        default: //NON APPLICA NIENTE
            return self.foregroundColor(nil)
        }
    }
    func tintIf(_ apply: Bool, _ color: Palette, _ otherwise: Palette = .orange) -> some View {
        return apply ? self.tint(color) : self.tint(otherwise)
    }
    func orange() -> some View {
        return self.foregroundColor(Color(.systemOrange))
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
            .scaledToFit()
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
            .orange()
    }
}
