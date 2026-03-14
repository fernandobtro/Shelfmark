//
//  FetchReadingListByIdUseCaseImplTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

final class FetchReadingListByIdUseCaseImplTests: XCTestCase {

    func test_execute_whenRepositoryReturnsList_returnsSameListAndCallsRepoWithId() async throws {
        let mock = MockReadingListRepository()
        let listId = UUID()
        let list = makeSampleReadingList(id: listId, name: "My List")
        mock.fetchListByIdResult = list

        let useCase = FetchReadingListByIdUseCaseImpl(repository: mock)

        let result = try await useCase.execute(listId: listId)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, listId)
        XCTAssertEqual(result?.name, "My List")
        XCTAssertEqual(mock.fetchListByIdCallCount, 1)
    }

    func test_execute_whenRepositoryReturnsNil_returnsNil() async throws {
        let mock = MockReadingListRepository()
        mock.fetchListByIdResult = nil

        let useCase = FetchReadingListByIdUseCaseImpl(repository: mock)

        let result = try await useCase.execute(listId: UUID())

        XCTAssertNil(result)
        XCTAssertEqual(mock.fetchListByIdCallCount, 1)
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockReadingListRepository()
        mock.errorToThrow = TestError.fake

        let useCase = FetchReadingListByIdUseCaseImpl(repository: mock)

        do {
            _ = try await useCase.execute(listId: UUID())
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.fetchListByIdCallCount, 1)
    }
}
