//
//  DeleteQuoteUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol DeleteQuoteUseCaseProtocol {
    func execute(quoteId: UUID) async throws
}
