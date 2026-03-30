//
//  FetchQuotesUseCaseImplTests.swift
//  ShelfmarKTests
//
//  Purpose: Unit tests for `FetchQuotesUseCaseImplTests`.
//

import XCTest
@testable import Shelfmark

/// Unit tests for `FetchQuotesUseCaseImplTests`.
@MainActor
final class FetchQuotesUseCaseImplTests: XCTestCase {

    func test_execute_returnsQuotesFromRepository() async throws {
        let mock = MockQuoteRepository()
        let quotes = [makeSampleQuote(text: "A"), makeSampleQuote(text: "B")]
        mock.fetchAllResult = quotes

        let sut = FetchQuotesUseCaseImpl(repository: mock)

        let result = try await sut.execute()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.map { $0.text }, ["A", "B"])
        XCTAssertEqual(mock.fetchAllCallCount, 1)
    }

    func test_execute_whenRepositoryEmpty_returnsEmptyArray() async throws {
        let mock = MockQuoteRepository()
        mock.fetchAllResult = []

        let sut = FetchQuotesUseCaseImpl(repository: mock)

        let result = try await sut.execute()

        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(mock.fetchAllCallCount, 1)
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockQuoteRepository()
        mock.errorToThrow = TestError.fake

        let sut = FetchQuotesUseCaseImpl(repository: mock)

        do {
            _ = try await sut.execute()
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.fetchAllCallCount, 1)
    }
}
