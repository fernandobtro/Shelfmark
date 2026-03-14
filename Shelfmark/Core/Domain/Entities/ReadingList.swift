//
//  ReadingList.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

/// Lista de lectura creada por el usuario.
/// En dominio solo necesitamos los metadatos de la lista; los libros se obtienen aparte.
struct ReadingList: Equatable, Identifiable {
    let id: UUID
    var name: String
    let createdAt: Date
    var iconName: String?
    var notes: String?
}
