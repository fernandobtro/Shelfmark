//
//  MockQuotesUseCases.swift
//  ShelfmarKTests
//

import Foundation
@testable import Shelfmark

final class MockFetchQuotesUseCase: FetchQuotesUseCaseProtocol {
    var quotesToReturn: [Quote] = []
    var errorToThrow: Error?
    var executeCallCount = 0

    func execute() async throws -> [Quote] {
        executeCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return quotesToReturn
    }

    func executePaginated(limit: Int, offset: Int) async throws -> [Quote] {
        executeCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return Array(quotesToReturn.dropFirst(offset).prefix(limit))
    }
}

final class MockSaveQuoteUseCase: SaveQuoteUseCaseProtocol {
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastQuoteReceived: Quote?

    func execute(quote: Quote) async throws {
        executeCallCount += 1
        lastQuoteReceived = quote
        if let errorToThrow { throw errorToThrow }
    }
}

final class MockDeleteQuoteUseCase: DeleteQuoteUseCaseProtocol {
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastQuoteIdReceived: UUID?

    func execute(quoteId: UUID) async throws {
        executeCallCount += 1
        lastQuoteIdReceived = quoteId
        if let errorToThrow { throw errorToThrow }
    }
}

final class MockFetchQuoteByIdUseCase: FetchQuoteByIdUseCaseProtocol {
    var quoteToReturn: Quote?
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastQuoteIdReceived: UUID?

    func execute(quoteId: UUID) async throws -> Quote? {
        executeCallCount += 1
        lastQuoteIdReceived = quoteId
        if let errorToThrow { throw errorToThrow }
        return quoteToReturn
    }
}

final class MockFetchLibraryUseCase: FetchLibraryUseCaseProtocol {
    var booksToReturn: [Book] = []
    var errorToThrow: Error?
    var executeCallCount = 0

    func execute() async throws -> [Book] {
        executeCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return booksToReturn
    }

    func executePaginated(limit: Int, offset: Int) async throws -> [Book] {
        executeCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return Array(booksToReturn.dropFirst(offset).prefix(limit))
    }
}

final class MockFetchBookDetailUseCase: FetchBookDetailUseCaseProtocol {
    var bookToReturn: Book?
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastBookIdReceived: UUID?

    func execute(bookId: UUID) async throws -> Book? {
        executeCallCount += 1
        lastBookIdReceived = bookId
        if let errorToThrow { throw errorToThrow }
        return bookToReturn
    }
}
