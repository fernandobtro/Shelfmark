//
//  CalculateReadingStatsUseCaseImpl.swift
//  Shelfmark
//

import Foundation

final class CalculateReadingStatsUseCaseImpl: CalculateReadingStatsUseCaseProtocol {
    static let shared = CalculateReadingStatsUseCaseImpl()

    private init() {}

    func execute(books: [Book]) -> ReadingStats {
        var completed = 0
        var inProgress = 0
        var pending = 0
        var pagesRead = 0
        var progressSum: Double = 0
        var progressCount = 0

        for book in books {
            switch book.readingStatus {
            case .read:
                completed += 1
            case .reading:
                inProgress += 1
            case .pending, .none:
                pending += 1
            }

            if let currentPage = book.currentPage {
                pagesRead += currentPage
            }

            if let progress = book.readingProgressFraction {
                progressSum += progress
                progressCount += 1
            }
        }

        let average = progressCount == 0 ? 0 : progressSum / Double(progressCount)
        let completionRate = books.isEmpty ? 0 : Double(completed) / Double(books.count)

        return ReadingStats(
            totalBooks: books.count,
            completedBooks: completed,
            inProgressBooks: inProgress,
            pendingBooks: pending,
            totalPagesRead: pagesRead,
            averageProgress: average,
            completionRate: completionRate
        )
    }
}
