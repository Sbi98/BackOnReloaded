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
    func overlayIf<Content:View>(_ show: Binding<Bool>, toOverlay: Content, alignment: Alignment = .center) -> some View {
        return show.wrappedValue ? self.overlay(AnyView(toOverlay), alignment: alignment) : self.overlay(AnyView(EmptyView()))
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
    case task
    case expiredTask
    case taskGray
    case detailedTaskHeaderBG
    case detailedTaskHeaderBGBACKUP
    case button
    case yellow
    case orange
    case red
    case gray
    case gray2
    case gray3
    case black
    case white
    case primary
    case secondary
    case test
}

fileprivate func getColor(_ color: Palette) -> Color {
    switch color {
    case .task:
        return Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1))
    case .expiredTask:
        return Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    case .detailedTaskHeaderBG: //dovrà avvicinarsi al caso .task
        return Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1)).opacity(0.9)
    case .detailedTaskHeaderBGBACKUP: //dovrà avvicinarsi al caso .task
        return Color(#colorLiteral(red: 0.9294117647, green: 0.8392156863, blue: 0.6901960784, alpha: 1))
    case .button:
        return Color(#colorLiteral(red: 0.9910104871, green: 0.6643157601, blue: 0.3115140796, alpha: 1))
    case .taskGray:
        return Color(UIColor.secondaryLabel.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)))
    case .yellow:
        return Color(.systemYellow)
    case .orange:
        return Color(.systemOrange)
    case .red:
        return Color(.systemRed)
    case .gray:
        return Color(.systemGray)
    case .gray3:
        return Color(.systemGray3)
    case .white:
        return Color.white
    case .test: //SOLO DI TEST
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? Color(.green) : Color(.red)
    case .secondary:
        return Color.secondary
    default:
        return Color.primary
    }
}

/*
 GUIDA AI COLORI
 - aggiungere alla palette i nomi dei colori
 - aggiungere i case corrispondenti nella funzione tint
 - applicare tint agli elementi desiderati
 
 N.B. i Color(.system^^^^^) si adattano automaticamente ai cambi light/dark mode e viceversa
 (e le coppie di colori utilizzati sono studiate da Apple. Le potete vedere a questo link: https://www.avanderlee.com/wp-content/uploads/2019/02/SemanticUI_app_Aaron_Brethorst.png)
 
 Se usate colori non .system^^^^^ e che devono cambiare a seconda della modalità nella vista in cui chiamate la .tint aggiungete
 @Environment(.\colorScheme) var colorScheme
 */
extension View {
    func tint(_ color: Palette) -> some View {
        return self.foregroundColor(getColor(color))
    }
    func tintIf(_ apply: Bool, _ color: Palette, _ otherwise: Palette = .orange) -> some View {
        return apply ? self.tint(color) : self.tint(otherwise)
    }
    func background(_ color: Palette) -> some View {
        return self.background(getColor(color))
    }
    func backgroundIf(_ apply: Bool, _ color: Palette, _ otherwise: Palette = .orange) -> some View {
        return apply ? self.background(color) : self.background(otherwise)
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
