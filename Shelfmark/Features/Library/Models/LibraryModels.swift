//
//  LibraryModels.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Library presentation models and enums used by view and view model layers.
//

import Foundation

/// Defines Library-specific UI models for filters, sections, and sorting/grouping options.
enum SortOption: Hashable, CaseIterable {
    case title
    case author
    
    var displayName: String {
        switch self {
        case .title:
            "Título"
        case .author:
            "Autor"
        }
    }
}

enum GroupOption: Hashable, CaseIterable {
    case publisher
    case author
    case none
    
    var displayName: String {
        switch self {
        case .publisher:
            "Editorial"
        case .author:
            "Autor"
        case .none:
            "Ninguno"
        }
    }
}

enum FilterOption: Hashable {
    case none
    case read
    case reading
    case favorites
    case pending

    var displayName: String {
        switch self {
        case .none:
            "" // Not displayed as an actionable button
        case .read:
            "Leídos"
        case .reading:
            "Leyendo"
        case .favorites:
            "Favoritos"
        case .pending:
            "Por leer"
        }
    }
}

struct LibrarySection: Identifiable {
    var categoryName: String
    var books: [Book]

    var id: String { categoryName }

    init(categoryName: String, books: [Book]) {
        self.categoryName = categoryName
        self.books = books
    }
}
