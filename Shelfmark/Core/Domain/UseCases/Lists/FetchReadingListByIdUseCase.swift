//
//  FetchReadingListByIdUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `FetchReadingListByIdUseCase`.
//

import Foundation

/// Domain use case contract `FetchReadingListByIdUseCase`.
protocol FetchReadingListByIdUseCaseProtocol {
    func execute(listId: UUID) async throws -> ReadingList?
}
