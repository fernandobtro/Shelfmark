//
//  CreateReadingListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `CreateReadingListUseCase`.
//

import Foundation

/// Domain use case contract `CreateReadingListUseCase`.
protocol CreateReadingListUseCaseProtocol {
    func execute(name: String) async throws -> ReadingList
}
