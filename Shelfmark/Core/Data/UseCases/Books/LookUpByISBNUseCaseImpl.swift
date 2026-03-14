//
//  LookUpByISBNUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 12/03/26.
//

import Foundation

final class LookUpByISBNUseCaseImpl: LookUpByISBNUseCaseProtocol {
    private let repository: BookLookUpByISBNRepositoryProtocol
    
    init(repository: BookLookUpByISBNRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(isbn: String) async throws -> Book? {
        let trimmed = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        return try await repository.fetch(byISBN: trimmed)
    }
}

