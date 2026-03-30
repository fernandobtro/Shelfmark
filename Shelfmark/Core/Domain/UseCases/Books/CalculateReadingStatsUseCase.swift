//
//  CalculateReadingStatsUseCase.swift
//  Shelfmark
//
//  Purpose: Domain use case contract `CalculateReadingStatsUseCase`.
//

import Foundation

/// Domain use case contract `CalculateReadingStatsUseCase`.
protocol CalculateReadingStatsUseCaseProtocol {
    func execute(books: [Book]) -> ReadingStats
}
