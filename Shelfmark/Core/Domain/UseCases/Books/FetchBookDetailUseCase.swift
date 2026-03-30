//
//  FetchBookDetailUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Domain use case contract `FetchBookDetailUseCase`.
//

import Foundation

/// Domain use case contract `FetchBookDetailUseCase`.
protocol FetchBookDetailUseCaseProtocol {
    func execute(bookId: UUID) async throws -> Book?
}
