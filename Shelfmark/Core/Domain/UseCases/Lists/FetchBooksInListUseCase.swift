//
//  FetchBooksInListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `FetchBooksInListUseCase`.
//

import Foundation

/// Domain use case contract `FetchBooksInListUseCase`.
protocol FetchBooksInListUseCaseProtocol {
    func execute(listId: UUID) async throws -> [Book]
}
