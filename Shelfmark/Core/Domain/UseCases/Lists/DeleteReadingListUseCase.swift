//
//  DeleteReadingListUseCase.swift
//  Shelfmark
//
//  Purpose: Domain use case contract `DeleteReadingListUseCase`.
//

import Foundation

/// Domain use case contract `DeleteReadingListUseCase`.
protocol DeleteReadingListUseCaseProtocol {
    func execute(id: UUID) async throws
}
