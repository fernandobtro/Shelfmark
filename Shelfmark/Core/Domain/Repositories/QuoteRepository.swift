//
//  QuoteRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol QuoteRepositoryProtocol {
    func fetchAll() async throws -> [Quote]
    func fetch(by id: UUID) async throws -> Quote?
    func save(_ quote: Quote) async throws
    func delete(by quoteId: UUID) async throws
}
