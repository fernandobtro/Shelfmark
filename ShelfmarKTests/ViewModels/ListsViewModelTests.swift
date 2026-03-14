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

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock
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

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock
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

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock
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

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock
        )
        sut.newListName = "   "

        await sut.createList()

        XCTAssertEqual(createMock.executeCallCount, 0)
    }

    func test_createList_whenCreateUseCaseThrows_stateIsError() async {
        let fetchMock = MockFetchReadingListUseCase()
        let createMock = MockCreateReadingListUseCase()
        createMock.errorToThrow = TestError.fake

        let sut = ListsViewModel(
            fetchReadingListsUseCase: fetchMock,
            createReadingListUseCase: createMock
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
}
