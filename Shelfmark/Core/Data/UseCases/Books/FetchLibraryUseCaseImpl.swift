//
//  FetchLibraryUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

final class FetchLibraryUseCaseImpl: FetchLibraryUseCaseProtocol {

    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Book] {
        try await repository.fetchAll()
    }
}

