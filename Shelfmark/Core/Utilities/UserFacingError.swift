//
//  UserFacingError.swift
//  Shelfmark
//
//  Purpose: Centralized helper that maps internal errors into safe user-facing messages.
//

import Foundation

/// Normalizes error presentation with fallback copy for UI states.
enum UserFacingError {
    static func message(_ error: Error, fallback: String) -> String {
        let raw = (error as NSError).localizedDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = raw.lowercased()

        if raw.isEmpty { return fallback }
        if lower.contains("multiple validation errors occurred") { return fallback }
        if lower.contains("the operation couldn") { return fallback }
        if lower.contains("swiftdata") || lower.contains("nscocoaerror") { return fallback }

        if lower.contains("internet") || lower.contains("network") || lower.contains("offline") {
            return "Parece que no hay conexión a internet. Intenta de nuevo."
        }

        return fallback
    }
}
