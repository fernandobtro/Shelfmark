//
//  SaveQuoteUseCaseImplTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

final class SaveQuoteUseCaseImplTests: XCTestCase {

    func test_execute_callsRepositorySaveWithQuote() async throws {
        let mock = MockQuoteRepository()
        let quote = makeSampleQuote(text: "Saved quote")

        let sut = SaveQuoteUseCaseImpl(repository: mock)

        try await sut.execute(quote: quote)

        XCTAssertEqual(mock.saveCallCount, 1)
        XCTAssertEqual(mock.lastSaveQuote?.id, quote.id)
        XCTAssertEqual(mock.lastSaveQuote?.text, "Saved quote")
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockQuoteRepository()
        mock.errorToThrow = TestError.fake
        let quote = makeSampleQuote()

        let sut = SaveQuoteUseCaseImpl(repository: mock)

        do {
            try await sut.execute(quote: quote)
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.saveCallCount, 1)
    }
}
