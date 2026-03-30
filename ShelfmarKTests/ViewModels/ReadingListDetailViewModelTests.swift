//
//  ReadingListDetailViewModelTests.swift
//  ShelfmarKTests
//
//  Purpose: Unit tests for `ReadingListDetailViewModelTests`.
//

import XCTest
@testable import Shelfmark

/// Unit tests for `ReadingListDetailViewModelTests`.
@MainActor
final class ReadingListDetailViewModelTests: XCTestCase {

    func test_load_whenBothUseCasesReturn_stateIsLoaded() async {
        let listId = UUID()
        let list = makeSampleReadingList(id: listId, name: "My List")
        let books = [makeSampleBook(title: "Book 1")]

        let fetchListMock = MockFetchReadingListByIdUseCase()
        fetchListMock.listToReturn = list

        let fetchBooksMock = MockFetchBooksInListUseCase()
        fetchBooksMock.booksToReturn = books

        let addMock = MockAddBookToReadingListUseCase()
        let removeMock = MockRemoveBookFromReadingListUseCase()

        let sut = ReadingListDetailViewModel(
            listId: listId,
            fetchBooksInListUseCase: fetchBooksMock,
            fetchReadingListByIdUseCase: fetchListMock,
            addBookToReadingListUseCase: addMock,
            removeBookFromReadingListUseCase: removeMock
        )

        await sut.load()

        if case .loaded(let loadedList, let loadedBooks) = sut.state {
            XCTAssertEqual(loadedList.id, listId)
            XCTAssertEqual(loadedList.name, "My List")
            XCTAssertEqual(loadedBooks.count, 1)
            XCTAssertEqual(loadedBooks.first?.title, "Book 1")
        } else {
            XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertEqual(fetchListMock.executeCallCount, 1)
        XCTAssertEqual(fetchListMock.lastListIdReceived, listId)
        XCTAssertEqual(fetchBooksMock.executeCallCount, 1)
        XCTAssertEqual(fetchBooksMock.lastListIdReceived, listId)
    }

    func test_load_whenFetchListReturnsNil_stateIsError() async {
        let listId = UUID()
        let fetchListMock = MockFetchReadingListByIdUseCase()
        fetchListMock.listToReturn = nil

        let fetchBooksMock = MockFetchBooksInListUseCase()
        let addMock = MockAddBookToReadingListUseCase()
        let removeMock = MockRemoveBookFromReadingListUseCase()

        let sut = ReadingListDetailViewModel(
            listId: listId,
            fetchBooksInListUseCase: fetchBooksMock,
            fetchReadingListByIdUseCase: fetchListMock,
            addBookToReadingListUseCase: addMock,
            removeBookFromReadingListUseCase: removeMock
        )

        await sut.load()

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("No se encontró la lista"))
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(fetchListMock.executeCallCount, 1)
        XCTAssertEqual(fetchBooksMock.executeCallCount, 0)
    }

    func test_load_whenFetchListThrows_stateIsError() async {
        let listId = UUID()
        let fetchListMock = MockFetchReadingListByIdUseCase()
        fetchListMock.errorToThrow = TestError.fake

        let fetchBooksMock = MockFetchBooksInListUseCase()
        let addMock = MockAddBookToReadingListUseCase()
        let removeMock = MockRemoveBookFromReadingListUseCase()

        let sut = ReadingListDetailViewModel(
            listId: listId,
            fetchBooksInListUseCase: fetchBooksMock,
            fetchReadingListByIdUseCase: fetchListMock,
            addBookToReadingListUseCase: addMock,
            removeBookFromReadingListUseCase: removeMock
        )

        await sut.load()

        if case .error = sut.state {
            // OK
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(fetchListMock.executeCallCount, 1)
    }

    func test_addBook_callsAddUseCaseAndReloads() async {
        let listId = UUID()
        let list = makeSampleReadingList(id: listId, name: "List")
        let bookId = UUID()

        let fetchListMock = MockFetchReadingListByIdUseCase()
        fetchListMock.listToReturn = list

        let fetchBooksMock = MockFetchBooksInListUseCase()
        fetchBooksMock.booksToReturn = []

        let addMock = MockAddBookToReadingListUseCase()

        let removeMock = MockRemoveBookFromReadingListUseCase()

        let sut = ReadingListDetailViewModel(
            listId: listId,
            fetchBooksInListUseCase: fetchBooksMock,
            fetchReadingListByIdUseCase: fetchListMock,
            addBookToReadingListUseCase: addMock,
            removeBookFromReadingListUseCase: removeMock
        )
        await sut.load()

        fetchBooksMock.booksToReturn = [makeSampleBook(id: bookId)]

        await sut.addBook(bookId: bookId)

        XCTAssertEqual(addMock.executeCallCount, 1)
        XCTAssertEqual(addMock.lastBookIdReceived, bookId)
        XCTAssertEqual(addMock.lastListIdReceived, listId)
        XCTAssertEqual(fetchListMock.executeCallCount, 2)
        XCTAssertEqual(fetchBooksMock.executeCallCount, 2)
    }

    func test_removeBook_callsRemoveUseCaseAndReloads() async {
        let listId = UUID()
        let list = makeSampleReadingList(id: listId, name: "List")
        let bookId = UUID()

        let fetchListMock = MockFetchReadingListByIdUseCase()
        fetchListMock.listToReturn = list

        let fetchBooksMock = MockFetchBooksInListUseCase()
        fetchBooksMock.booksToReturn = [makeSampleBook(id: bookId)]

        let addMock = MockAddBookToReadingListUseCase()

        let removeMock = MockRemoveBookFromReadingListUseCase()

        let sut = ReadingListDetailViewModel(
            listId: listId,
            fetchBooksInListUseCase: fetchBooksMock,
            fetchReadingListByIdUseCase: fetchListMock,
            addBookToReadingListUseCase: addMock,
            removeBookFromReadingListUseCase: removeMock
        )
        await sut.load()

        fetchBooksMock.booksToReturn = []

        await sut.removeBook(bookId: bookId)

        XCTAssertEqual(removeMock.executeCallCount, 1)
        XCTAssertEqual(removeMock.lastBookIdReceived, bookId)
        XCTAssertEqual(removeMock.lastListIdReceived, listId)
        XCTAssertEqual(fetchListMock.executeCallCount, 2)
        XCTAssertEqual(fetchBooksMock.executeCallCount, 2)
    }
}
