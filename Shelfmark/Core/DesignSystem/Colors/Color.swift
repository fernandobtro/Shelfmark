//
//  Color.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Design-system color tokens and theme accessors used across Shelfmark UI.
//

import Foundation
import SwiftUI

/// Centralizes color palette values used by app-wide SwiftUI styling.
extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let primaryGreen = Color("PrimaryGreen")
    let mainBackground = Color("MainBackground")
    let secondaryBackground = Color("SecondaryBackground")
    let textPrimary = Color("TextPrimary")
}


