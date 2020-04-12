//
//  UIKitInterface.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 12/04/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class CustomHostingController<Content:View>: UIHostingController<AnyView>, UIAdaptivePresentationControllerDelegate {
    let hideStatusBar: Bool
    
    init(
        contentView: Content,
        hideStatusBar: Bool = false,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        preventModalDismiss: Bool = false
    ) {
        self.hideStatusBar = hideStatusBar
        super.init(rootView: AnyView(EmptyView()))
        self.modalPresentationStyle = modalPresentationStyle
        self.isModalInPresentation = preventModalDismiss
        self.presentationController?.delegate = self
        self.rootView = AnyView(contentView.environmentObject(ViewControllerHolder(self)))
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alertToPresent = UIAlertController(title: "You edited some fields", message: "Do you do want to discard changes?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Discard", style: .destructive) { _ in
            presentationController.presentedViewController.dismiss(animated: true, completion: nil)
        }
        alertToPresent.view.tintColor = .systemOrange
        alertToPresent.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertToPresent.addAction(action)
        presentationController.presentedViewController.present(alertToPresent, animated: true, completion: nil)
    }
}

class ViewControllerHolder: ObservableObject {
    var value: UIViewController
    @Published var isEditing = false
    init(_ viewController: UIViewController) {
        self.value = viewController
    }
    func presentViewInChildVC<Content: View>(
        _ viewToPresent: Content,
        hideStatusBar: Bool = false,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        preventModalDismiss: Bool = false
    ){
        value.present(CustomHostingController(contentView: viewToPresent, hideStatusBar: hideStatusBar, modalPresentationStyle: modalPresentationStyle, preventModalDismiss: preventModalDismiss), animated: true, completion: nil)
    }
    func dismissVC() {
        value.dismiss(animated: true, completion: nil)
    }
    func preventModalDismiss(_ prevent: Bool) {
        value.isModalInPresentation = prevent
    }
    func setEditMode(_ isEditing: Bool) {
        self.isEditing = isEditing
        value.isModalInPresentation = isEditing
    }
    func toggleEditMode() {
        isEditing.toggle()
        value.isModalInPresentation = isEditing
    }
}

extension UIViewController {
    static var main: UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
}
