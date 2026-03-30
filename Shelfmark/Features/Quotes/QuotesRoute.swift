//
//  QuotesRoute.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Navigation route definitions for Quotes flows and nested destinations.
//

import Foundation

/// Encapsulates strongly typed navigation targets used by the Quotes tab.
enum QuotesRoute: Hashable {
    case addQuote
    case addQuoteWithText(String)
    case editQuote(quoteId: UUID)
    case quoteDetail(quoteId: UUID)
    case bookQuotes(bookId: UUID)
    case authorQuotes(authorName: String)
    case bookDetail(bookId: UUID)
}
