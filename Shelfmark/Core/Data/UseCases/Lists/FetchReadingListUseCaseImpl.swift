//
//  FetchReadingListUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

final class FetchReadingListUseCaseImpl: FetchReadingListUseCaseProtocol {
    private let repository: ReadingListRepositoryProtocol

    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ReadingList] {
        try await repository.fetchAllLists()
    }
}
