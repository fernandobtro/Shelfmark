//
//  CreateReadingListUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

final class CreateReadingListUseCaseImpl: CreateReadingListUseCaseProtocol {
    private let repository: ReadingListRepositoryProtocol
    
    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(name: String) async throws -> ReadingList {
        try await repository.createList(name: name)
    }
}
