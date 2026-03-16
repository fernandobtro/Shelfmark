//
//  DismissKeyboardModifier.swift
//  Shelfmark
//
//  Modifier que muestra una capa transparente cuando el teclado está visible;
//  al tocar esa capa se cierra el teclado. Aplicar en vistas con búsqueda o formularios.
//

import SwiftUI
import UIKit

struct DismissKeyboardModifier: ViewModifier {
    @State private var isKeyboardVisible = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if isKeyboardVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil,
                                from: nil,
                                for: nil
                            )
                        }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardVisible = false
            }
    }
}

extension View {

    func dismissKeyboardOnTapOutside() -> some View {
        modifier(DismissKeyboardModifier())
    }
}
