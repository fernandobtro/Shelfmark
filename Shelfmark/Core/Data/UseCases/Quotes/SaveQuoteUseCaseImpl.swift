//
//  SaveQuoteUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

final class SaveQuoteUseCaseImpl: SaveQuoteUseCaseProtocol {
    
    private let repository: QuoteRepositoryProtocol
    
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(quote: Quote) async throws {
        try await repository.save(quote)
    }
}
