//
//  DeleteQuoteUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `DeleteQuoteUseCase`.
//

import Foundation

/// Domain use case contract `DeleteQuoteUseCase`.
protocol DeleteQuoteUseCaseProtocol {
    func execute(quoteId: UUID) async throws
}
