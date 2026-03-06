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
    case all
    case reading
    case favorites
    
    var displayName: String {
        switch self {
        case .all:
            "Todos"
        case .reading:
            "Leyendo"
        case .favorites:
            "Favoritos"
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
