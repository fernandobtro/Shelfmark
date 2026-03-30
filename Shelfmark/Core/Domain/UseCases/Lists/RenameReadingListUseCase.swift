//
//  RenameReadingListUseCase.swift
//  Shelfmark
//
//  Purpose: Domain use case contract `RenameReadingListUseCase`.
//

import Foundation

/// Domain use case contract `RenameReadingListUseCase`.
protocol RenameReadingListUseCaseProtocol {
    func execute(id: UUID, newName: String) async throws
}
