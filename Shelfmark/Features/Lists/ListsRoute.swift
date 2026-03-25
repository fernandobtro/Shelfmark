//
//  ListsRoute.swift
//  Shelfmark
//

import Foundation

/// Rutas de navegación en la pestaña Listas (evita colisión con `UUID` para libro vs lista).
enum ListsRoute: Hashable {
    case list(UUID)
    case book(UUID)
}
