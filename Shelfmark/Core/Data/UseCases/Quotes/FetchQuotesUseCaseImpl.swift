//
//  FetchQuotesUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

final class FetchQuotesUseCaseImpl: FetchQuotesUseCaseProtocol {
    
    private let repository: QuoteRepositoryProtocol
    
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Quote] {
        try await repository.fetchAll()
    }
}
