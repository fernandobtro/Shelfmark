//
//  LookUpByISBNUseCaseImplTests.swift
//  ShelfmarKTests
//
//  Example test per category with guidance comments for additional coverage.
//
//  Purpose: Unit tests for `LookUpByISBNUseCaseImplTests`.
//

import XCTest
@testable import Shelfmark

/// Unit tests for `LookUpByISBNUseCaseImplTests`.
@MainActor
final class LookUpByISBNUseCaseImplTests: XCTestCase {

    // MARK: - Implemented Example

    /// When the repository returns a book, the use case returns it and calls the repository with a trimmed ISBN.
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

    // MARK: - Additional Cases

    /// When the repository returns `nil`, the use case also returns `nil` and calls the repository once.
    func test_execute_cuandoRepositorioDevuelveNil_useCaseDevuelveNil() async throws {
        let mockRepo = MockBookLookUpByISBNRepository()
        mockRepo.resultToReturn = nil

        let sut = LookUpByISBNUseCaseImpl(repository: mockRepo)

        let result = try await sut.execute(isbn: "123")

        XCTAssertNil(result)
        XCTAssertEqual(mockRepo.fetchCallCount, 1)
        XCTAssertEqual(mockRepo.lastISBNReceived, "123")
    }

    /// When the repository throws, the use case propagates the same error.
    func test_execute_cuandoRepositorioLanzaError_useCasePropagaElError() async {
        enum DummyError: Error, Equatable {
            case failure
        }

        let mockRepo = MockBookLookUpByISBNRepository()
        mockRepo.errorToThrow = DummyError.failure

        let sut = LookUpByISBNUseCaseImpl(repository: mockRepo)

        do {
            _ = try await sut.execute(isbn: "123")
            XCTFail("Expected use case to throw an error")
        } catch let error as DummyError {
            XCTAssertEqual(error, .failure)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }

        XCTAssertEqual(mockRepo.fetchCallCount, 1)
        XCTAssertEqual(mockRepo.lastISBNReceived, "123")
    }
}
