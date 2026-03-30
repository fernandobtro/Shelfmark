//
//  FetchQuotesUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `FetchQuotesUseCase`.
//

import Foundation

/// Domain use case contract `FetchQuotesUseCase`.
protocol FetchQuotesUseCaseProtocol {
    func execute() async throws -> [Quote]
    func executePaginated(limit: Int, offset: Int) async throws -> [Quote]
}
