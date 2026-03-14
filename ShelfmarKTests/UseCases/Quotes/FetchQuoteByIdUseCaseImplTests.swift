//
//  FetchQuoteByIdUseCaseImplTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

final class FetchQuoteByIdUseCaseImplTests: XCTestCase {

    func test_execute_whenRepositoryReturnsQuote_returnsSameQuote() async throws {
        let mock = MockQuoteRepository()
        let quoteId = UUID()
        let quote = makeSampleQuote(id: quoteId, text: "Found")
        mock.fetchByIdResult = quote

        let sut = FetchQuoteByIdUseCaseImpl(repository: mock)

        let result = try await sut.execute(quoteId: quoteId)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, quoteId)
        XCTAssertEqual(result?.text, "Found")
        XCTAssertEqual(mock.fetchByIdCallCount, 1)
        XCTAssertEqual(mock.lastFetchById, quoteId)
    }

    func test_execute_whenRepositoryReturnsNil_returnsNil() async throws {
        let mock = MockQuoteRepository()
        mock.fetchByIdResult = nil

        let sut = FetchQuoteByIdUseCaseImpl(repository: mock)

        let result = try await sut.execute(quoteId: UUID())

        XCTAssertNil(result)
        XCTAssertEqual(mock.fetchByIdCallCount, 1)
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockQuoteRepository()
        mock.errorToThrow = TestError.fake

        let sut = FetchQuoteByIdUseCaseImpl(repository: mock)

        do {
            _ = try await sut.execute(quoteId: UUID())
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.fetchByIdCallCount, 1)
    }
}
