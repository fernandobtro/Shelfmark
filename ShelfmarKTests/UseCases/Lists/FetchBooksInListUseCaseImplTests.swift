//
//  FetchBooksInListUseCaseImplTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

final class FetchBooksInListUseCaseImplTests: XCTestCase {

    func test_execute_whenRepositoryReturnsBooks_returnsSameBooksAndCallsRepoWithListId() async throws {
        let mock = MockReadingListRepository()
        let listId = UUID()
        let books = [makeSampleBook(title: "A"), makeSampleBook(title: "B")]
        mock.fetchBooksInListResult = books

        let useCase = FetchBooksInListUseCaseImpl(repository: mock)

        let result = try await useCase.execute(listId: listId)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.map(\.title), ["A", "B"])
        XCTAssertEqual(mock.fetchBooksCalls, [listId])
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockReadingListRepository()
        mock.errorToThrow = TestError.fake

        let useCase = FetchBooksInListUseCaseImpl(repository: mock)

        do {
            _ = try await useCase.execute(listId: UUID())
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.fetchBooksCalls.count, 1)
    }
}
