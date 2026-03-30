//
//  DeleteQuoteUseCaseImplTests.swift
//  ShelfmarKTests
//
//  Purpose: Unit tests for `DeleteQuoteUseCaseImplTests`.
//

import XCTest
@testable import Shelfmark

/// Unit tests for `DeleteQuoteUseCaseImplTests`.
@MainActor
final class DeleteQuoteUseCaseImplTests: XCTestCase {

    func test_execute_callsRepositoryDeleteWithQuoteId() async throws {
        let mock = MockQuoteRepository()
        let quoteId = UUID()

        let sut = DeleteQuoteUseCaseImpl(repository: mock)

        try await sut.execute(quoteId: quoteId)

        XCTAssertEqual(mock.deleteCallCount, 1)
        XCTAssertEqual(mock.lastDeleteQuoteId, quoteId)
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockQuoteRepository()
        mock.errorToThrow = TestError.fake
        let quoteId = UUID()

        let sut = DeleteQuoteUseCaseImpl(repository: mock)

        do {
            try await sut.execute(quoteId: quoteId)
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.deleteCallCount, 1)
    }
}
