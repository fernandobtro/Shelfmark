//
//  FetchQuotesUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol FetchQuotesUseCaseProtocol {
    func execute() async throws -> [Quote]
}
