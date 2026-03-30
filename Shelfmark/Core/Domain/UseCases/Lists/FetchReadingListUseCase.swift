//
//  FetchReadingListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `FetchReadingListUseCase`.
//

import Foundation

/// Domain use case contract `FetchReadingListUseCase`.
protocol FetchReadingListUseCaseProtocol {
    func execute() async throws -> [ReadingList]
    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList]
}
