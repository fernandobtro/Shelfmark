//
//  LibraryGridLayoutOption.swift
//  Shelfmark
//
//  Created by Cursor on 24/03/26.
//
//  Purpose: Domain entity `LibraryGridLayoutOption`.
//

import Foundation

/// Domain entity `LibraryGridLayoutOption`.
enum LibraryGridLayoutOption: String, CaseIterable, Identifiable, Codable {
    case compact
    case standard
    case comfortable

    var id: String { rawValue }

    var minimumColumnWidth: Double {
        switch self {
        case .compact: return 110
        case .standard: return 140
        case .comfortable: return 170
        }
    }

    var displayName: String {
        switch self {
        case .compact: return "Compacto"
        case .standard: return "Estándar"
        case .comfortable: return "Amplio"
        }
    }
}

