//
//  DiscoverSheet.swift
//  BackOn
//
//  Created by Giancarlo Sorrentino on 29/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

//
//  BottomSheetView.swift
//
//  Created by Majid Jabrayilov
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.3
}

struct DiscoverDetailedSheet<Content: View>: View {
    @Binding var isOpen: Bool
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    
    @GestureState private var translation: CGFloat = 0
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
        ).onTapGesture {
            self.isOpen.toggle()
        }
    }
    
    init(isOpen: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.minHeight = -40 //invece di mostrarla chiusa, la spinge fuori dallo schermo
        self.maxHeight = UIScreen.main.bounds.height - 300 //valore da cambiare
        self.content = content()
        self._isOpen = isOpen
    }
    
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    self.indicator.padding()
                    self.content
                }
                .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(Constants.radius)
                .frame(height: geometry.size.height, alignment: .bottom)
                .offset(y: max(self.offset + self.translation, 0))
                .animation(.interactiveSpring(response:  0.45, dampingFraction:  0.86, blendDuration:  0.7))
                .gesture(
                    DragGesture().updating(self.$translation) { value, state, _ in
                        state = value.translation.height
                    }.onEnded { value in
                        let snapDistance = self.maxHeight * Constants.snapRatio
                        guard abs(value.translation.height) > snapDistance else {
                            return
                        }
                        self.isOpen = value.translation.height < 0
                    }
                )
            }
        }
    }
}


struct DiscoverSheetView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverDetailedSheet(isOpen: .constant(false)) {
            Rectangle().fill(Color.red)
        }.edgesIgnoringSafeArea(.all)
    }
}

