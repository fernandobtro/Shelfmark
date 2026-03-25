//
//  QuotesRoute.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

/// Rutas de navegación dentro del tab Citas: detalle de cita, citas por libro o por autor.
enum QuotesRoute: Hashable {
    case quoteDetail(quoteId: UUID)
    case bookQuotes(bookId: UUID)
    case authorQuotes(authorName: String)
    case bookDetail(bookId: UUID)
}
