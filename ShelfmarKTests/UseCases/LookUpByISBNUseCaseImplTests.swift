//
//  LookUpByISBNUseCaseImplTests.swift
//  ShelfmarKTests
//
//  Un test de ejemplo por categoría + comentarios con los que faltan y qué validar.
//

import XCTest
@testable import Shelfmark

@MainActor
final class LookUpByISBNUseCaseImplTests: XCTestCase {

    // MARK: - Ejemplo implementado

    /// Cuando el repositorio devuelve un libro, el use case lo devuelve y llama al repo con el ISBN ya recortado.
    func test_execute_trimmaElISBN_yDevuelveElLibroDelRepositorio() async throws {
        let mockRepo = MockBookLookUpByISBNRepository()
        let book = Book(
            id: UUID(),
            isbn: "978-0123456789",
            authors: [Author(id: UUID(), name: "Autor Test")],
            title: "Libro Test",
            numberOfPages: 100,
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
        mockRepo.resultToReturn = book

        let sut = LookUpByISBNUseCaseImpl(repository: mockRepo)

        let result = try await sut.execute(isbn: "  978-0123456789  ")

        XCTAssertEqual(result, book)
        XCTAssertEqual(mockRepo.fetchCallCount, 1)
        XCTAssertEqual(mockRepo.lastISBNReceived, "978-0123456789")
    }

    // MARK: - Más casos

    /// Cuando el repositorio devuelve nil, el use case también devuelve nil y llama una sola vez al repo.
    func test_execute_cuandoRepositorioDevuelveNil_useCaseDevuelveNil() async throws {
        let mockRepo = MockBookLookUpByISBNRepository()
        mockRepo.resultToReturn = nil

        let sut = LookUpByISBNUseCaseImpl(repository: mockRepo)

        let result = try await sut.execute(isbn: "123")

        XCTAssertNil(result)
        XCTAssertEqual(mockRepo.fetchCallCount, 1)
        XCTAssertEqual(mockRepo.lastISBNReceived, "123")
    }

    /// Cuando el repositorio lanza error, el use case lo propaga.
    func test_execute_cuandoRepositorioLanzaError_useCasePropagaElError() async {
        enum DummyError: Error, Equatable {
            case failure
        }

        let mockRepo = MockBookLookUpByISBNRepository()
        mockRepo.errorToThrow = DummyError.failure

        let sut = LookUpByISBNUseCaseImpl(repository: mockRepo)

        do {
            _ = try await sut.execute(isbn: "123")
            XCTFail("Se esperaba que el use case lanzara error")
        } catch let error as DummyError {
            XCTAssertEqual(error, .failure)
        } catch {
            XCTFail("Se lanzó un tipo de error inesperado: \(error)")
        }

        XCTAssertEqual(mockRepo.fetchCallCount, 1)
        XCTAssertEqual(mockRepo.lastISBNReceived, "123")
    }
}
