//
//  SaveQuoteUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol SaveQuoteUseCaseProtocol {
    func execute(quote: Quote) async throws
}
