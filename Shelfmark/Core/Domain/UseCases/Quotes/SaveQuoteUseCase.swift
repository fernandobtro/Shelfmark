//
//  SaveQuoteUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `SaveQuoteUseCase`.
//

import Foundation

/// Domain use case contract `SaveQuoteUseCase`.
protocol SaveQuoteUseCaseProtocol {
    func execute(quote: Quote) async throws
}
