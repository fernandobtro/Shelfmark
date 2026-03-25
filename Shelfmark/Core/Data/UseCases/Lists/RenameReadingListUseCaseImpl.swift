//
//  RenameReadingListUseCaseImpl.swift
//  Shelfmark
//

import Foundation

final class RenameReadingListUseCaseImpl: RenameReadingListUseCaseProtocol {
    private let repository: ReadingListRepositoryProtocol

    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID, newName: String) async throws {
        try await repository.renameList(id: id, name: newName)
    }
}
