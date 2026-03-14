//
//  DeleteQuoteUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

final class DeleteQuoteUseCaseImpl: DeleteQuoteUseCaseProtocol {
    
    private let repository: QuoteRepositoryProtocol
    
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(quoteId: UUID) async throws {
        try await repository.delete(by: quoteId)
    }
}
