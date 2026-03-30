//
//  CreateReadingListUseCaseImplTest.swift
//  ShelfmarKTests
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Shelfmark component `CreateReadingListUseCaseImplTest`.
//

import XCTest
@testable import Shelfmark

/// Shelfmark component `CreateReadingListUseCaseImplTest`.
@MainActor
final class CreateReadingListUseCaseImplTest: XCTestCase {

    func test_execute_whenRepositorySucceeds_returnsListAndCallsRepoWithName() async throws {
        let mock = MockReadingListRepository()

        let useCase = CreateReadingListUseCaseImpl(repository: mock)

        let result = try await useCase.execute(name: "Sci-Fi")

        XCTAssertEqual(mock.createListCalls.count, 1)
        XCTAssertEqual(mock.createListCalls.first, "Sci-Fi")
        XCTAssertEqual(result.name, "Sci-Fi")
    }

    func test_execute_whenRepositoryThrows_propagatesError() async {
        let mock = MockReadingListRepository()
        mock.errorToThrow = TestError.fake

        let useCase = CreateReadingListUseCaseImpl(repository: mock)

        do {
            _ = try await useCase.execute(name: "Sci-Fi")
            XCTFail("Expected error")
        } catch let error as TestError {
            XCTAssertEqual(error, .fake)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(mock.createListCalls.count, 1)
    }
}
