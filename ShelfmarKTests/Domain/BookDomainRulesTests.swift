//
//  BookDomainRulesTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

final class BookDomainRulesTests: XCTestCase {

    func test_readingProgressFraction_whenMissingData_returnsNil() {
        let noCurrent = makeBook(numberOfPages: 200, currentPage: nil)
        let noTotal = makeBook(numberOfPages: nil, currentPage: 40)
        let invalidTotal = makeBook(numberOfPages: 0, currentPage: 1)

        XCTAssertNil(noCurrent.readingProgressFraction)
        XCTAssertNil(noTotal.readingProgressFraction)
        XCTAssertNil(invalidTotal.readingProgressFraction)
    }

    func test_readingProgressFraction_whenValid_returnsFraction() throws {
        let book = makeBook(numberOfPages: 200, currentPage: 50)
        let fraction = try XCTUnwrap(book.readingProgressFraction)

        XCTAssertEqual(fraction, 0.25, accuracy: 0.0001)
    }

    func test_readingProgressFraction_clampsOutOfRangePage() throws {
        let belowRange = makeBook(numberOfPages: 200, currentPage: 0)
        let aboveRange = makeBook(numberOfPages: 200, currentPage: 999)
        let belowFraction = try XCTUnwrap(belowRange.readingProgressFraction)
        let aboveFraction = try XCTUnwrap(aboveRange.readingProgressFraction)

        XCTAssertEqual(belowFraction, 0.005, accuracy: 0.0001)
        XCTAssertEqual(aboveFraction, 1.0, accuracy: 0.0001)
    }

    func test_validationErrorMessage_whenEmptyText_returnsNil() {
        let message = Book.validationErrorMessage(currentPageText: "   ", numberOfPages: 200)
        XCTAssertNil(message)
    }

    func test_validationErrorMessage_whenNotNumber_returnsMessage() {
        let message = Book.validationErrorMessage(currentPageText: "abc", numberOfPages: 200)
        XCTAssertEqual(message, "Introduce un número válido para la página actual.")
    }

    func test_validationErrorMessage_whenPageLessThanOne_returnsMessage() {
        let message = Book.validationErrorMessage(currentPageText: "0", numberOfPages: 200)
        XCTAssertEqual(message, "La página debe ser 1 o mayor.")
    }

    func test_validationErrorMessage_whenMissingTotalPages_returnsMessage() {
        let message = Book.validationErrorMessage(currentPageText: "10", numberOfPages: nil)
        XCTAssertEqual(message, "Indica el número de páginas del libro (Editar) antes de registrar la página actual.")
    }

    func test_validationErrorMessage_whenPageExceedsTotal_returnsMessage() {
        let message = Book.validationErrorMessage(currentPageText: "250", numberOfPages: 200)
        XCTAssertEqual(message, "La página no puede superar el total (200).")
    }

    func test_validationErrorMessage_whenValidInput_returnsNil() {
        let message = Book.validationErrorMessage(currentPageText: "120", numberOfPages: 300)
        XCTAssertNil(message)
    }

    private func makeBook(numberOfPages: Int?, currentPage: Int?) -> Book {
        Book(
            id: UUID(),
            isbn: "978-0-00-000000-0",
            authors: [Author(id: UUID(), name: "Author")],
            title: "Domain Book",
            numberOfPages: numberOfPages,
            publisher: nil,
            publicationDate: nil,
            thumbnailURL: nil,
            bookDescription: nil,
            subtitle: nil,
            language: "es",
            isFavorite: false,
            readingStatus: .none,
            currentPage: currentPage
        )
    }
}
