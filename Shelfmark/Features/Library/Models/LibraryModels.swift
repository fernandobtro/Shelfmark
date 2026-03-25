//
//  LibraryModels.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation

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
            "" // No se muestra como botón
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
