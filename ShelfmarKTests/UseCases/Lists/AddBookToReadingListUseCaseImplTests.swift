//
//  AddBookToReadingListUseCaseImplTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

final class AddBookToReadingListUseCaseImplTests: XCTestCase {

    func test_execute_callsRepositoryWithBookIdAndListId() async throws {
        let mock = MockReadingListRepository()
        let bookId = UUID()
        let listId = UUID()

        let useCase = AddBookToReadingListImpl(repository: mock)

        try await useCase.execute(bookId: bookId, listId: listId)

        XCTAssertEqual(mock.addBookCalls.count, 1)
        XCTAssertEqual(mock.addBookCalls.first?.bookId, bookId)
        XCTAssertEqual(mock.addBookCalls.first?.listId, listId)
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockReadingListRepository()
        mock.errorToThrow = TestError.fake

        let useCase = AddBookToReadingListImpl(repository: mock)

        do {
            try await useCase.execute(bookId: UUID(), listId: UUID())
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.addBookCalls.count, 1)
    }
}
