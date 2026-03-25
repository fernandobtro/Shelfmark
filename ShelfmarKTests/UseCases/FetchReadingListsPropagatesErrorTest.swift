//
//  FetchReadingListsPropagatesErrorTest.swift
//  ShelfmarKTests
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import XCTest
@testable import Shelfmark

@MainActor
final class FetchReadingListsPropagatesErrorTest: XCTestCase {
    func testFetchReadingListsPropagatesError() async {

        // GIVEN
        let mock = MockReadingListRepository()
        mock.errorToThrow = TestError.fake

        let useCase = FetchReadingListUseCaseImpl(repository: mock)

        // WHEN / THEN
        do {
            _ = try await useCase.execute()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? TestError, .fake)
        }
        XCTAssertEqual(mock.fetchAllCallCount, 1)
    }
}
