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
    
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] {
        try await repository.fetchPaginated(limit: limit, offset: offset)
    }
}

