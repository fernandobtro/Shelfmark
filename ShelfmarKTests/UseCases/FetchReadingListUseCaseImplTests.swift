//
//  FetchReadingListUseCaseImplTests.swift
//  ShelfmarKTests
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import XCTest
@testable import Shelfmark

@MainActor
final class FetchReadingListUseCaseImplTests: XCTestCase {

    func test_execute_whenRepositoryReturnsLists_returnsSameListsAndCallsRepoOnce() async throws {
        let mock = MockReadingListRepository()
        let list = ReadingList(
            id: UUID(),
            name: "Fantasy",
            createdAt: Date(),
            iconName: nil,
            notes: nil
        )
        mock.fetchAllListsResult = [list]

        let useCase = FetchReadingListUseCaseImpl(repository: mock)

        let result = try await useCase.execute()
        let firstName = result.first?.name

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(firstName, "Fantasy")
        XCTAssertEqual(mock.fetchAllCallCount, 1)
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockReadingListRepository()
        mock.errorToThrow = TestError.fake

        let useCase = FetchReadingListUseCaseImpl(repository: mock)

        do {
            _ = try await useCase.execute()
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.fetchAllCallCount, 1)
    }
}
