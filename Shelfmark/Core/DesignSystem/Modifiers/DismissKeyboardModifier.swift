//
//  DismissKeyboardModifier.swift
//  Shelfmark
//
//  Modifier that adds a behind-content tap layer while the keyboard is visible;
//  tapping outside focused controls dismisses the keyboard. Use on search/forms screens.
//
//  Purpose: View modifier that dismisses keyboard when tapping outside focused inputs.
//

import SwiftUI
import UIKit

/// Adds reusable keyboard-dismiss behavior to form and search screens.
///
/// Uses a **background** tap target instead of an overlay so interactive controls
/// (text fields, buttons) remain hit-testable while the keyboard is visible.
/// A full-screen overlay on top of content blocked taps in UI and broke XCUITest typing.
struct DismissKeyboardModifier: ViewModifier {
    @State private var isKeyboardVisible = false

    func body(content: Content) -> some View {
        content
            .background {
                if isKeyboardVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
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
