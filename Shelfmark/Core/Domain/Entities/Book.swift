//
//  Book.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

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
    /// Página actual de lectura (opcional). Independiente del total de páginas del volumen.
    let currentPage: Int?
}

extension Book {
    /// Progreso entre 0 y 1, o `nil` si falta página actual, total o el total no es válido.
    var readingProgressFraction: Double? {
        guard let current = currentPage,
              let total = numberOfPages,
              total > 0 else { return nil }
        let clamped = min(max(current, 1), total)
        return Double(clamped) / Double(total)
    }

    /// Valida texto de página actual frente al total conocido. `text` vacío → sin error (se interpreta como borrar).
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

/// SwiftData no persiste enums personalizados. Usamos String como rawValue para guardar en BookEntity.
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
