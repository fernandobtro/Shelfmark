//
//  MockLookUpByISBNUseCase.swift
//  ShelfmarKTests
//

import Foundation
@testable import Shelfmark

/// Mock del use case de lookup por ISBN para tests del BookScannerViewModel.
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
