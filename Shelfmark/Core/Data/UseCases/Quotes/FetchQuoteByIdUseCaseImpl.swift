//
//  FetchQuoteByIdUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

final class FetchQuoteByIdUseCaseImpl: FetchQuoteByIdUseCaseProtocol {
    
    private let repository: QuoteRepositoryProtocol
    
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(quoteId: UUID) async throws -> Quote? {
        try await repository.fetch(by: quoteId)
    }
}
