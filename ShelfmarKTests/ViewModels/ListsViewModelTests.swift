//
//  ListsViewModelTests.swift
//  ShelfmarKTests
//

import XCTest
@testable import Shelfmark

@MainActor
final class ListsViewModelTests: XCTestCase {

    func test_loadLists_whenUseCaseReturnsLists_stateIsLoaded() async {
        let fetchMock = MockFetchReadingListUseCase()
        let lists = [makeSampleReadingList(name: "A"), makeSampleReadingList(name: "B")]
        fetchMock.listsToReturn = lists

        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )

        await sut.loadLists()

        if case .loaded(let loaded) = sut.state {
            XCTAssertEqual(loaded.count, 2)
            XCTAssertEqual(loaded.map(\.name), ["A", "B"])
        } else {
            XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertEqual(fetchMock.executeCallCount, 1)
    }

    func test_loadLists_whenUseCaseThrows_stateIsError() async {
        let fetchMock = MockFetchReadingListUseCase()
        fetchMock.errorToThrow = TestError.fake

        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )

        await sut.loadLists()

        if case .error(let message) = sut.state {
            XCTAssertFalse(message.isEmpty)
            XCTAssertTrue(message.contains("No se pudieron cargar"))
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(fetchMock.executeCallCount, 1)
    }

    func test_createList_whenNameNotEmpty_callsCreateUseCaseAndReloadsLists() async {
        let fetchMock = MockFetchReadingListUseCase()
        fetchMock.listsToReturn = []

        let createMock = MockCreateReadingListUseCase()
        createMock.listToReturn = makeSampleReadingList(name: "New")
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )
        sut.newListName = "New"
        sut.isPresentingCreateSheet = true

        await sut.createList()

        XCTAssertEqual(createMock.executeCallCount, 1)
        XCTAssertEqual(createMock.lastNameReceived, "New")
        XCTAssertEqual(fetchMock.executeCallCount, 1)
        XCTAssertEqual(sut.newListName, "")
        XCTAssertFalse(sut.isPresentingCreateSheet)
    }

    func test_createList_whenNameEmpty_doesNotCallCreateUseCase() async {
        let fetchMock = MockFetchReadingListUseCase()
        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )
        sut.newListName = "   "

        await sut.createList()

        XCTAssertEqual(createMock.executeCallCount, 0)
    }

    func test_createList_whenCreateUseCaseThrows_stateIsError() async {
        let fetchMock = MockFetchReadingListUseCase()
        let createMock = MockCreateReadingListUseCase()
        createMock.errorToThrow = TestError.fake
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )
        sut.newListName = "New"

        await sut.createList()

        if case .error(let message) = sut.state {
            XCTAssertFalse(message.isEmpty)
            XCTAssertTrue(message.contains("Error al crear"))
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(createMock.executeCallCount, 1)
    }

    func test_renameList_whenNameIsValid_callsUseCaseAndReloadsLists() async {
        let fetchMock = MockFetchReadingListUseCase()
        fetchMock.listsToReturn = [makeSampleReadingList(name: "Original")]
        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()
        let listId = UUID()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )

        await sut.renameList(id: listId, newName: "  Renombrada  ")

        XCTAssertEqual(renameMock.executeCallCount, 1)
        XCTAssertEqual(renameMock.lastIdReceived, listId)
        XCTAssertEqual(renameMock.lastNameReceived, "Renombrada")
        XCTAssertEqual(fetchMock.executeCallCount, 1)
    }

    func test_renameList_whenNameIsEmpty_doesNotCallUseCase() async {
        let fetchMock = MockFetchReadingListUseCase()
        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )

        await sut.renameList(id: UUID(), newName: "   ")

        XCTAssertEqual(renameMock.executeCallCount, 0)
        XCTAssertEqual(fetchMock.executeCallCount, 0)
    }

    func test_renameList_whenUseCaseThrows_setsErrorState() async {
        let fetchMock = MockFetchReadingListUseCase()
        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        renameMock.errorToThrow = TestError.fake
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )

        await sut.renameList(id: UUID(), newName: "Renombrada")

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("Error al renombrar"))
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(renameMock.executeCallCount, 1)
    }

    func test_deleteList_whenUseCaseSucceeds_callsUseCaseAndReloadsLists() async {
        let fetchMock = MockFetchReadingListUseCase()
        fetchMock.listsToReturn = []
        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()
        let listId = UUID()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )

        await sut.deleteList(id: listId)

        XCTAssertEqual(deleteMock.executeCallCount, 1)
        XCTAssertEqual(deleteMock.lastIdReceived, listId)
        XCTAssertEqual(fetchMock.executeCallCount, 1)
    }

    func test_deleteList_whenUseCaseThrows_setsErrorState() async {
        let fetchMock = MockFetchReadingListUseCase()
        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()
        deleteMock.errorToThrow = TestError.fake

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )

        await sut.deleteList(id: UUID())

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("Error al eliminar"))
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(deleteMock.executeCallCount, 1)
    }

    func test_createList_whenDuplicateName_setsValidationMessageAndDoesNotCallCreateUseCase() async {
        let existing = makeSampleReadingList(name: "Libros 2026")
        let fetchMock = MockFetchReadingListUseCase()
        fetchMock.listsToReturn = [existing]
        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )
        await sut.loadLists()
        sut.newListName = "  libros 2026  "

        await sut.createList()

        XCTAssertEqual(createMock.executeCallCount, 0)
        XCTAssertEqual(sut.inputErrorMessage, "Ya existe una lista con ese nombre.")
    }

    func test_renameList_whenDuplicateName_setsValidationMessageAndDoesNotCallRenameUseCase() async {
        let listA = makeSampleReadingList(id: UUID(), name: "Pendientes")
        let listB = makeSampleReadingList(id: UUID(), name: "Sci-Fi")
        let fetchMock = MockFetchReadingListUseCase()
        fetchMock.listsToReturn = [listA, listB]
        let createMock = MockCreateReadingListUseCase()
        let fetchBooksMock = MockFetchBooksInListUseCase()
        let renameMock = MockRenameReadingListUseCase()
        let deleteMock = MockDeleteReadingListUseCase()

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock,
            fetchBooksInListUseCase: fetchBooksMock,
            renameReadingListUseCase: renameMock,
            deleteReadingListUseCase: deleteMock
        )
        await sut.loadLists()

        await sut.renameList(id: listB.id, newName: "  pendientes ")

        XCTAssertEqual(renameMock.executeCallCount, 0)
        XCTAssertEqual(sut.inputErrorMessage, "Ya existe una lista con ese nombre.")
    }
}
