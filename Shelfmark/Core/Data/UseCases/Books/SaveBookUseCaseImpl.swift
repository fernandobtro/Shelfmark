//
//  SaveBookUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Implements `SaveBookUseCase` using data repositories.
//

import Foundation

/// Implements `SaveBookUseCase` using data repositories.
final class SaveBookUseCaseImpl: SaveBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol

    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ book: Book) async throws {
        try await repository.save(book)
    }
}

