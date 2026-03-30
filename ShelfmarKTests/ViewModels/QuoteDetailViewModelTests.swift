//
//  QuoteDetailViewModelTests.swift
//  ShelfmarKTests
//
//  Purpose: Unit tests for `QuoteDetailViewModelTests`.
//

import XCTest
@testable import Shelfmark

/// Unit tests for `QuoteDetailViewModelTests`.
@MainActor
final class QuoteDetailViewModelTests: XCTestCase {

    func test_load_whenQuoteExists_stateIsLoaded() async {
        let quoteId = UUID()
        let bookId = UUID()
        let quote = makeSampleQuote(id: quoteId, text: "Detail quote", bookId: bookId)
        let book = makeSampleBook(id: bookId, title: "The Book")

        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        fetchQuoteMock.quoteToReturn = quote
        let fetchBookMock = MockFetchBookDetailUseCase()
        fetchBookMock.bookToReturn = book
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = QuoteDetailViewModel(
            quoteId: quoteId,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchBookDetailUseCase: fetchBookMock,
            deleteQuoteUseCase: deleteMock
        )

        await sut.load()

        if case .loaded(let loadedQuote, let loadedBook) = sut.state {
            XCTAssertEqual(loadedQuote.id, quoteId)
            XCTAssertEqual(loadedQuote.text, "Detail quote")
            XCTAssertEqual(loadedBook?.title, "The Book")
        } else {
            XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertEqual(fetchQuoteMock.executeCallCount, 1)
        XCTAssertEqual(fetchQuoteMock.lastQuoteIdReceived, quoteId)
        XCTAssertEqual(fetchBookMock.executeCallCount, 1)
        XCTAssertEqual(fetchBookMock.lastBookIdReceived, bookId)
    }

    func test_load_whenQuoteNotFound_stateIsError() async {
        let quoteId = UUID()
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        fetchQuoteMock.quoteToReturn = nil
        let fetchBookMock = MockFetchBookDetailUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = QuoteDetailViewModel(
            quoteId: quoteId,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchBookDetailUseCase: fetchBookMock,
            deleteQuoteUseCase: deleteMock
        )

        await sut.load()

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("No se encontró la cita"))
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(fetchQuoteMock.executeCallCount, 1)
        XCTAssertEqual(fetchBookMock.executeCallCount, 0)
    }

    func test_load_whenFetchQuoteThrows_stateIsError() async {
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        fetchQuoteMock.errorToThrow = TestError.fake
        let fetchBookMock = MockFetchBookDetailUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = QuoteDetailViewModel(
            quoteId: UUID(),
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchBookDetailUseCase: fetchBookMock,
            deleteQuoteUseCase: deleteMock
        )

        await sut.load()

        if case .error = sut.state {
            // OK
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(fetchQuoteMock.executeCallCount, 1)
    }

    func test_deleteQuote_callsDeleteUseCaseAndSetsDeleted() async {
        let quoteId = UUID()
        let quote = makeSampleQuote(id: quoteId)
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        fetchQuoteMock.quoteToReturn = quote
        let fetchBookMock = MockFetchBookDetailUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = QuoteDetailViewModel(
            quoteId: quoteId,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchBookDetailUseCase: fetchBookMock,
            deleteQuoteUseCase: deleteMock
        )
        await sut.load()

        await sut.deleteQuote()

        XCTAssertEqual(deleteMock.executeCallCount, 1)
        XCTAssertEqual(deleteMock.lastQuoteIdReceived, quoteId)
        if case .deleted = sut.state {
            // OK
        } else {
            XCTFail("Expected .deleted, got \(sut.state)")
        }
    }

    func test_deleteQuote_whenDeleteThrows_stateIsError() async {
        let quoteId = UUID()
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        fetchQuoteMock.quoteToReturn = makeSampleQuote(id: quoteId)
        let fetchBookMock = MockFetchBookDetailUseCase()
        let deleteMock = MockDeleteQuoteUseCase()
        deleteMock.errorToThrow = TestError.fake

        let sut = QuoteDetailViewModel(
            quoteId: quoteId,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchBookDetailUseCase: fetchBookMock,
            deleteQuoteUseCase: deleteMock
        )
        await sut.load()

        await sut.deleteQuote()

        if case .error = sut.state {
            // OK
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(deleteMock.executeCallCount, 1)
    }
}
