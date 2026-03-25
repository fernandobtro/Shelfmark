//
//  MockQuoteRepository.swift
//  ShelfmarKTests
//

import Foundation
@testable import Shelfmark

final class MockQuoteRepository: QuoteRepositoryProtocol {
    var fetchAllResult: [Quote] = []
    var fetchByIdResult: Quote?
    var errorToThrow: Error?

    var fetchAllCallCount = 0
    var fetchByIdCallCount = 0
    var saveCallCount = 0
    var deleteCallCount = 0
    var lastSaveQuote: Quote?
    var lastDeleteQuoteId: UUID?
    var lastFetchById: UUID?

    func fetchAll() async throws -> [Quote] {
        fetchAllCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return fetchAllResult
    }

    func fetchPaginated(limit: Int, offset: Int) async throws -> [Quote] {
        fetchAllCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return Array(fetchAllResult.dropFirst(offset).prefix(limit))
    }

    func fetch(by id: UUID) async throws -> Quote? {
        fetchByIdCallCount += 1
        lastFetchById = id
        if let errorToThrow { throw errorToThrow }
        return fetchByIdResult
    }

    func save(_ quote: Quote) async throws {
        saveCallCount += 1
        lastSaveQuote = quote
        if let errorToThrow { throw errorToThrow }
    }

    func delete(by quoteId: UUID) async throws {
        deleteCallCount += 1
        lastDeleteQuoteId = quoteId
        if let errorToThrow { throw errorToThrow }
    }
}
