//
//  DeleteReadingListUseCaseImpl.swift
//  Shelfmark
//
//  Purpose: Implements `DeleteReadingListUseCase` using data repositories.
//

import Foundation

/// Implements `DeleteReadingListUseCase` using data repositories.
final class DeleteReadingListUseCaseImpl: DeleteReadingListUseCaseProtocol {
    private let repository: ReadingListRepositoryProtocol

    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID) async throws {
        try await repository.deleteList(id: id)
    }
}
