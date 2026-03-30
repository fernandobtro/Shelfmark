//
//  QuotesViewModelTests.swift
//  ShelfmarKTests
//
//  Purpose: Unit tests for `QuotesViewModelTests`.
//

import XCTest
@testable import Shelfmark

/// Unit tests for `QuotesViewModelTests`.
@MainActor
final class QuotesViewModelTests: XCTestCase {

    func test_loadQuotes_whenUseCasesReturn_stateIsLoaded() async {
        let fetchQuotesMock = MockFetchQuotesUseCase()
        let bookId = UUID()
        fetchQuotesMock.quotesToReturn = [makeSampleQuote(text: "Quote 1", bookId: bookId)]

        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [makeSampleBook(id: bookId, title: "My Book")]

        let deleteMock = MockDeleteQuoteUseCase()

        let sut = QuotesViewModel(
            fetchQuotesUseCase: fetchQuotesMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )

        await sut.loadQuotes()

        if case .loaded(let quotes) = sut.state {
            XCTAssertEqual(quotes.count, 1)
            XCTAssertEqual(quotes.first?.text, "Quote 1")
        } else {
            XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertEqual(fetchQuotesMock.executeCallCount, 1)
        XCTAssertEqual(fetchLibraryMock.executeCallCount, 1)
    }

    func test_loadQuotes_whenFetchQuotesThrows_stateIsError() async {
        let fetchQuotesMock = MockFetchQuotesUseCase()
        fetchQuotesMock.errorToThrow = TestError.fake

        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = []

        let deleteMock = MockDeleteQuoteUseCase()

        let sut = QuotesViewModel(
            fetchQuotesUseCase: fetchQuotesMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )

        await sut.loadQuotes()

        if case .error(let message) = sut.state {
            XCTAssertFalse(message.isEmpty)
            XCTAssertTrue(message.contains("No se pudieron cargar"))
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(fetchQuotesMock.executeCallCount, 1)
    }

    func test_deleteQuote_callsDeleteUseCaseAndReloads() async {
        let quoteId = UUID()
        let bookId = UUID()

        let fetchQuotesMock = MockFetchQuotesUseCase()
        fetchQuotesMock.quotesToReturn = [makeSampleQuote(id: quoteId, text: "Quote", bookId: bookId)]

        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [makeSampleBook(id: bookId)]

        let deleteMock = MockDeleteQuoteUseCase()

        let sut = QuotesViewModel(
            fetchQuotesUseCase: fetchQuotesMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )
        await sut.loadQuotes()

        await sut.deleteQuote(quoteId: quoteId)

        XCTAssertEqual(deleteMock.executeCallCount, 1)
        XCTAssertEqual(deleteMock.lastQuoteIdReceived, quoteId)
        XCTAssertEqual(fetchQuotesMock.executeCallCount, 2)
    }

    func test_deleteQuote_whenDeleteThrows_stateIsError() async {
        let fetchQuotesMock = MockFetchQuotesUseCase()
        fetchQuotesMock.quotesToReturn = []

        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = []

        let deleteMock = MockDeleteQuoteUseCase()
        deleteMock.errorToThrow = TestError.fake

        let sut = QuotesViewModel(
            fetchQuotesUseCase: fetchQuotesMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )
        await sut.loadQuotes()

        await sut.deleteQuote(quoteId: UUID())

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("No se pudo eliminar"))
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(deleteMock.executeCallCount, 1)
    }

    func test_sectionedQuotes_byBook_groupsByBookTitle() async {
        let bookId = UUID()
        let fetchQuotesMock = MockFetchQuotesUseCase()
        fetchQuotesMock.quotesToReturn = [
            makeSampleQuote(text: "Q1", bookId: bookId),
            makeSampleQuote(text: "Q2", bookId: bookId)
        ]
        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [makeSampleBook(id: bookId, title: "Alpha")]
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = QuotesViewModel(
            fetchQuotesUseCase: fetchQuotesMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )
        sut.grouping = .byBook
        await sut.loadQuotes()

        let sections = sut.sectionedQuotes
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.key, "Alpha")
        XCTAssertEqual(sections.first?.quotes.count, 2)
    }
}
