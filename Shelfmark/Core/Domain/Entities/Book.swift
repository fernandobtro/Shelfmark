//
//  Book.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Domain entity `Book`.
//

import Foundation

/// Domain entity `Book`.
struct Book: Equatable, Identifiable {
    let id: UUID
    let isbn: String
    let authors: [Author]
    let title: String
    let numberOfPages: Int?
    let publisher: Publisher?
    let publicationDate: Date?
    let thumbnailURL: URL?
    let bookDescription: String?
    let subtitle: String?
    let language: String
    let isFavorite: Bool
    let readingStatus: ReadingStatus
    let currentPage: Int?
}

extension Book {
    /// Progress value in [0, 1], or `nil` when current/total pages are missing or invalid.
    var readingProgressFraction: Double? {
        guard let current = currentPage,
              let total = numberOfPages,
              total > 0 else { return nil }
        let clamped = min(max(current, 1), total)
        return Double(clamped) / Double(total)
    }

    /// Validates current-page input against known total pages. Empty `text` means clear value and is valid.
    static func validationErrorMessage(currentPageText: String, numberOfPages: Int?) -> String? {
        let trimmed = currentPageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        guard let page = Int(trimmed) else {
            return "Introduce un número válido para la página actual."
        }
        if page < 1 {
            return "La página debe ser 1 o mayor."
        }
        guard let total = numberOfPages, total > 0 else {
            return "Indica el número de páginas del libro (Editar) antes de registrar la página actual."
        }
        if page > total {
            return "La página no puede superar el total (\(total))."
        }
        return nil
    }
}

/// SwiftData does not persist custom enums directly, store `ReadingStatus` as raw string in `BookEntity`.
enum ReadingStatus: String, CaseIterable {
    case pending = "pending"
    case reading = "reading"
    case read = "read"
    case none = "none"

    var displayName: String {
        switch self {
        case .pending: return "Pendiente"
        case .reading: return "Leyendo"
        case .read: return "Leído"
        case .none: return "Ninguno"
        }
    }
}
