//
//  MockBookLookUpByISBNRepository.swift
//  ShelfmarKTests
//
//  Purpose: Shelfmark component `MockBookLookUpByISBNRepository`.
//

import Foundation
@testable import Shelfmark

/// Mock lookup-by-ISBN repository for use-case tests.
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
