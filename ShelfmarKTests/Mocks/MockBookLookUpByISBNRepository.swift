//
//  MockBookLookUpByISBNRepository.swift
//  ShelfmarKTests
//

import Foundation
@testable import Shelfmark

/// Mock del repositorio de lookup por ISBN para tests del use case.
final class MockBookLookUpByISBNRepository: BookLookUpByISBNRepositoryProtocol {
    var resultToReturn: Book?
    var errorToThrow: Error?
    var lastISBNReceived: String?
    var fetchCallCount = 0

    func fetch(byISBN isbn: String) async throws -> Book? {
        fetchCallCount += 1
        lastISBNReceived = isbn
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }
}
