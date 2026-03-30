//
//  QuoteRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Repository boundary `QuoteRepository`.
//

import Foundation

/// Repository boundary `QuoteRepository`.
protocol QuoteRepositoryProtocol {
    func fetchAll() async throws -> [Quote]
    func fetchPaginated(limit: Int, offset: Int) async throws -> [Quote]
    func fetch(by id: UUID) async throws -> Quote?
    func save(_ quote: Quote) async throws
    func delete(by quoteId: UUID) async throws
}
