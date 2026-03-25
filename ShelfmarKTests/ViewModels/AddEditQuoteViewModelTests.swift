//
//  AddEditQuoteViewModelTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

@MainActor
final class AddEditQuoteViewModelTests: XCTestCase {

    func test_load_addMode_setsBooksWithoutSelectingBook() async {
        let book = makeSampleBook(title: "First Book")
        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [book]

        let saveMock = MockSaveQuoteUseCase()
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = AddEditQuoteViewModel(
            mode: .add,
            saveQuoteUseCase: saveMock,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )

        await sut.load()

        XCTAssertEqual(sut.books.count, 1)
        XCTAssertNil(sut.selectedBookId)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(fetchLibraryMock.executeCallCount, 1)
        XCTAssertEqual(fetchQuoteMock.executeCallCount, 0)
    }

    func test_load_addWithInitialText_setsTextWithoutSelectingBook() async {
        let book = makeSampleBook()
        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [book]

        let saveMock = MockSaveQuoteUseCase()
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = AddEditQuoteViewModel(
            mode: .addWithInitialText("Scanned text"),
            saveQuoteUseCase: saveMock,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )

        await sut.load()

        XCTAssertEqual(sut.text, "Scanned text")
        XCTAssertNil(sut.selectedBookId)
        XCTAssertEqual(fetchLibraryMock.executeCallCount, 1)
    }

    func test_load_editMode_loadsQuoteAndFillsFields() async {
        let quoteId = UUID()
        let bookId = UUID()
        let quote = makeSampleQuote(id: quoteId, text: "Original", bookId: bookId, pageReference: "p. 42")
        let book = makeSampleBook(id: bookId)

        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [book]
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        fetchQuoteMock.quoteToReturn = quote
        let saveMock = MockSaveQuoteUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = AddEditQuoteViewModel(
            mode: .edit(quoteId: quoteId),
            saveQuoteUseCase: saveMock,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )

        await sut.load()

        XCTAssertTrue(sut.isEditMode)
        XCTAssertEqual(sut.text, "Original")
        XCTAssertEqual(sut.selectedBookId, bookId)
        XCTAssertEqual(sut.pageReference, "p. 42")
        XCTAssertEqual(fetchQuoteMock.executeCallCount, 1)
        XCTAssertEqual(fetchQuoteMock.lastQuoteIdReceived, quoteId)
    }

    func test_save_addMode_callsSaveUseCaseWithNewQuote() async {
        let book = makeSampleBook()
        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [book]
        let saveMock = MockSaveQuoteUseCase()
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = AddEditQuoteViewModel(
            mode: .add,
            saveQuoteUseCase: saveMock,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )
        await sut.load()
        sut.text = " New quote content "
        sut.selectedBook = book

        await sut.save()

        XCTAssertEqual(saveMock.executeCallCount, 1)
        XCTAssertEqual(saveMock.lastQuoteReceived?.text, "New quote content")
        XCTAssertEqual(saveMock.lastQuoteReceived?.bookId, book.id)
    }

    func test_save_whenTextEmpty_setsErrorMessage() async {
        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [makeSampleBook()]
        let saveMock = MockSaveQuoteUseCase()
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = AddEditQuoteViewModel(
            mode: .add,
            saveQuoteUseCase: saveMock,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )
        await sut.load()
        sut.text = "   "
        sut.selectedBook = sut.books.first

        await sut.save()

        XCTAssertEqual(saveMock.executeCallCount, 0)
        XCTAssertEqual(sut.errorMessage, "Escribe el texto de la cita.")
    }

    func test_save_whenNoBookSelected_setsErrorMessage() async {
        let fetchLibraryMock = MockFetchLibraryUseCase()
        fetchLibraryMock.booksToReturn = [makeSampleBook()]
        let saveMock = MockSaveQuoteUseCase()
        let fetchQuoteMock = MockFetchQuoteByIdUseCase()
        let deleteMock = MockDeleteQuoteUseCase()

        let sut = AddEditQuoteViewModel(
            mode: .add,
            saveQuoteUseCase: saveMock,
            fetchQuoteByIdUseCase: fetchQuoteMock,
            fetchLibraryUseCase: fetchLibraryMock,
            deleteQuoteUseCase: deleteMock
        )
        await sut.load()
        sut.text = "Quote"
        sut.selectedBook = nil

        await sut.save()

        XCTAssertEqual(saveMock.executeCallCount, 0)
        XCTAssertEqual(sut.errorMessage, "Elige un libro.")
    }
}
