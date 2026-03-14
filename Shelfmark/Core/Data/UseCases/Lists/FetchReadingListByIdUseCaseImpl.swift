//
//  FetchReadingListByIdUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

final class FetchReadingListByIdUseCaseImpl: FetchReadingListByIdUseCaseProtocol {
    private let repository: ReadingListRepositoryProtocol
    
    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(listId: UUID) async throws -> ReadingList? {
        try await repository.fetchList(byId: listId)
    }
}
