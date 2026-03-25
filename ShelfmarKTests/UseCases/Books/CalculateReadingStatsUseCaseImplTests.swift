//
//  CalculateReadingStatsUseCaseImplTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

final class CalculateReadingStatsUseCaseImplTests: XCTestCase {

    func test_execute_whenNoBooks_returnsZeroedStats() {
        let sut = CalculateReadingStatsUseCaseImpl.shared

        let stats = sut.execute(books: [])

        XCTAssertEqual(stats.totalBooks, 0)
        XCTAssertEqual(stats.completedBooks, 0)
        XCTAssertEqual(stats.inProgressBooks, 0)
        XCTAssertEqual(stats.pendingBooks, 0)
        XCTAssertEqual(stats.totalPagesRead, 0)
        XCTAssertEqual(stats.averageProgress, 0, accuracy: 0.0001)
        XCTAssertEqual(stats.completionRate, 0, accuracy: 0.0001)
    }

    func test_execute_whenMixedBooks_calculatesAllMetrics() {
        let sut = CalculateReadingStatsUseCaseImpl.shared
        let books: [Book] = [
            makeBook(status: .read, pages: 300, current: 300),
            makeBook(status: .reading, pages: 200, current: 50),
            makeBook(status: .pending, pages: nil, current: nil),
            makeBook(status: .none, pages: 100, current: nil)
        ]

        let stats = sut.execute(books: books)

        XCTAssertEqual(stats.totalBooks, 4)
        XCTAssertEqual(stats.completedBooks, 1)
        XCTAssertEqual(stats.inProgressBooks, 1)
        XCTAssertEqual(stats.pendingBooks, 2)
        XCTAssertEqual(stats.totalPagesRead, 350)
        XCTAssertEqual(stats.averageProgress, 0.625, accuracy: 0.0001)
        XCTAssertEqual(stats.completionRate, 0.25, accuracy: 0.0001)
    }

    private func makeBook(status: ReadingStatus, pages: Int?, current: Int?) -> Book {
        Book(
            id: UUID(),
            isbn: "978-0-00-000000-0",
            authors: [Author(id: UUID(), name: "Author")],
            title: "Stats Book",
            numberOfPages: pages,
            publisher: nil,
            publicationDate: nil,
            thumbnailURL: nil,
            bookDescription: nil,
            subtitle: nil,
            language: "es",
            isFavorite: false,
            readingStatus: status,
            currentPage: current
        )
    }
}
