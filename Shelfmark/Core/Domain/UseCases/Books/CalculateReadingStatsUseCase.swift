//
//  CalculateReadingStatsUseCase.swift
//  Shelfmark
//

import Foundation

protocol CalculateReadingStatsUseCaseProtocol {
    func execute(books: [Book]) -> ReadingStats
}
