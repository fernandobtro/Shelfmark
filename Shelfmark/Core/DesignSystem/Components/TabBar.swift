//
//  TabBar.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation

enum TabBar: String, CaseIterable {
    case library = "books.vertical.fill"
    case lists = "list.bullet"
    case quotes = "quote.bubble"
    case profile = "person.crop.circle"
    
    var title: String {
        switch self {
            
        case .library:
            "Biblioteca"
        case .lists:
            "Listas"
        case .quotes:
            "Citas"
        case .profile:
            "Perfil"
        }
    }
}
