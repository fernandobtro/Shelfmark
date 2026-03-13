//
//  BookScannerViewModelTests.swift
//  ShelfmarKTests
//
//  Un test de ejemplo por categoría + comentarios con los que faltan y qué validar.
//

import XCTest
@testable import Shelfmark

@MainActor
final class BookScannerViewModelTests: XCTestCase {

    // MARK: - Ejemplo implementado

    /// Cuando el use case devuelve un libro, el estado pasa a .loading y luego a .found(book).
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
            readingStatus: .none
        )
        mockUseCase.resultToReturn = book

        let sut = BookScannerViewModel(lookUpByISBNUseCase: mockUseCase)

        await sut.handleScannedCode("978-111")

        if case .found(let foundBook) = sut.state {
            XCTAssertEqual(foundBook, book)
        } else {
            XCTFail("Se esperaba state == .found(book), se obtuvo \(sut.state)")
        }
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastISBNReceived, "978-111")
    }

    // MARK: - Más casos

    func test_handleScannedCode_cuandoUseCaseDevuelveNil_estadoPasaANotFound() async {
        let mockUseCase = MockLookUpByISBNUseCase()
        mockUseCase.resultToReturn = nil

        let sut = BookScannerViewModel(lookUpByISBNUseCase: mockUseCase)

        await sut.handleScannedCode("123")

        if case .notFound(let isbn) = sut.state {
            XCTAssertEqual(isbn, "123")
        } else {
            XCTFail("Se esperaba state == .notFound(isbn:), se obtuvo \(sut.state)")
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
            XCTFail("Se esperaba state == .error, se obtuvo \(sut.state)")
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
