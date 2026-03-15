//
//  FetchQuoteByIdUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol FetchQuoteByIdUseCaseProtocol {
    func execute(quoteId: UUID) async throws -> Quote?
}
