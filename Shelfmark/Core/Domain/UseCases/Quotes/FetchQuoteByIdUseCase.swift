//
//  FetchQuoteByIdUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `FetchQuoteByIdUseCase`.
//

import Foundation

/// Domain use case contract `FetchQuoteByIdUseCase`.
protocol FetchQuoteByIdUseCaseProtocol {
    func execute(quoteId: UUID) async throws -> Quote?
}
