//
//  MockLookUpByISBNUseCase.swift
//  ShelfmarKTests
//
//  Purpose: Shelfmark component `MockLookUpByISBNUseCase`.
//

import Foundation
@testable import Shelfmark

/// Mock lookup-by-ISBN use case for `BookScannerViewModel` tests.
final class MockLookUpByISBNUseCase: LookUpByISBNUseCaseProtocol {
    var resultToReturn: Book?
    var errorToThrow: Error?
    var lastISBNReceived: String?
    var executeCallCount = 0

    func execute(isbn: String) async throws -> Book? {
        executeCallCount += 1
        lastISBNReceived = isbn
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }
}
