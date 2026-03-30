//
//  BookScannerViewModelTests.swift
//  ShelfmarKTests
//
//  Example test per category with guidance comments for additional coverage.
//
//  Purpose: Unit tests for `BookScannerViewModelTests`.
//

import XCTest
@testable import Shelfmark

/// Unit tests for `BookScannerViewModelTests`.
@MainActor
final class BookScannerViewModelTests: XCTestCase {

    // MARK: - Implemented Example

    /// When the use case returns a book, state moves to `.loading` and then `.found(book)`.
    func test_handleScannedCode_cuandoUseCaseDevuelveLibro_estadoPasaAFound() async {
        let mockUseCase = MockLookUpByISBNUseCase()
        let book = Book(
            id: UUID(),
            isbn: "978-111",
            authors: [Author(id: UUID(), name: "Autor")],
            title: "Libro",
            numberOfPages: nil,
            publisher: nil,
            publicationDate: nil,
            thumbnailURL: nil,
            bookDescription: nil,
            subtitle: nil,
            language: "es",
            isFavorite: false,
            readingStatus: .none,
            currentPage: nil
        )
        mockUseCase.resultToReturn = book

        let sut = BookScannerViewModel(lookUpByISBNUseCase: mockUseCase)

        await sut.handleScannedCode("978-111")

        if case .found(let foundBook) = sut.state {
            XCTAssertEqual(foundBook, book)
        } else {
            XCTFail("Expected state == .found(book), got \(sut.state)")
        }
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastISBNReceived, "978-111")
    }

    // MARK: - Additional Cases

    func test_handleScannedCode_cuandoUseCaseDevuelveNil_estadoPasaANotFound() async {
        let mockUseCase = MockLookUpByISBNUseCase()
        mockUseCase.resultToReturn = nil

        let sut = BookScannerViewModel(lookUpByISBNUseCase: mockUseCase)

        await sut.handleScannedCode("123")

        if case .notFound(let isbn) = sut.state {
            XCTAssertEqual(isbn, "123")
        } else {
            XCTFail("Expected state == .notFound(isbn:), got \(sut.state)")
        }
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastISBNReceived, "123")
    }

    func test_handleScannedCode_cuandoUseCaseLanzaError_estadoPasaAError() async {
        let mockUseCase = MockLookUpByISBNUseCase()
        mockUseCase.errorToThrow = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fallo"])

        let sut = BookScannerViewModel(lookUpByISBNUseCase: mockUseCase)

        await sut.handleScannedCode("123")

        if case .error(let message) = sut.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected state == .error, got \(sut.state)")
        }
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastISBNReceived, "123")
    }

    func test_reset_vuelveEstadoAIdle() async {
        let mockUseCase = MockLookUpByISBNUseCase()
        mockUseCase.resultToReturn = nil

        let sut = BookScannerViewModel(lookUpByISBNUseCase: mockUseCase)

        await sut.handleScannedCode("123")
        sut.reset()

        XCTAssertEqual(sut.state, .idle)
    }
}
