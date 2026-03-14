//
//  MockListsUseCases.swift
//  ShelfmarKTests
//

import Foundation
@testable import Shelfmark

final class MockFetchReadingListUseCase: FetchReadingListUseCaseProtocol {
    var listsToReturn: [ReadingList] = []
    var errorToThrow: Error?
    var executeCallCount = 0

    func execute() async throws -> [ReadingList] {
        executeCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return listsToReturn
    }
}

final class MockCreateReadingListUseCase: CreateReadingListUseCaseProtocol {
    var listToReturn: ReadingList?
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastNameReceived: String?

    func execute(name: String) async throws -> ReadingList {
        executeCallCount += 1
        lastNameReceived = name
        if let errorToThrow { throw errorToThrow }
        return listToReturn ?? makeSampleReadingList(name: name)
    }
}

final class MockFetchBooksInListUseCase: FetchBooksInListUseCaseProtocol {
    var booksToReturn: [Book] = []
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastListIdReceived: UUID?

    func execute(listId: UUID) async throws -> [Book] {
        executeCallCount += 1
        lastListIdReceived = listId
        if let errorToThrow { throw errorToThrow }
        return booksToReturn
    }
}

final class MockFetchReadingListByIdUseCase: FetchReadingListByIdUseCaseProtocol {
    var listToReturn: ReadingList?
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastListIdReceived: UUID?

    func execute(listId: UUID) async throws -> ReadingList? {
        executeCallCount += 1
        lastListIdReceived = listId
        if let errorToThrow { throw errorToThrow }
        return listToReturn
    }
}

final class MockAddBookToReadingListUseCase: AddBookToReadingListUseCaseProtocol {
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastBookIdReceived: UUID?
    var lastListIdReceived: UUID?

    func execute(bookId: UUID, listId: UUID) async throws {
        executeCallCount += 1
        lastBookIdReceived = bookId
        lastListIdReceived = listId
        if let errorToThrow { throw errorToThrow }
    }
}

final class MockRemoveBookFromReadingListUseCase: RemoveBookFromReadingListUseCaseProtocol {
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastBookIdReceived: UUID?
    var lastListIdReceived: UUID?

    func execute(bookId: UUID, listId: UUID) async throws {
        executeCallCount += 1
        lastBookIdReceived = bookId
        lastListIdReceived = listId
        if let errorToThrow { throw errorToThrow }
    }
}
