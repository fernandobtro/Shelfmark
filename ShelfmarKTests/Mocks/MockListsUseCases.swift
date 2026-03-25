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

    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList] {
        executeCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return Array(listsToReturn.dropFirst(offset).prefix(limit))
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

final class MockRenameReadingListUseCase: RenameReadingListUseCaseProtocol {
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastIdReceived: UUID?
    var lastNameReceived: String?

    func execute(id: UUID, newName: String) async throws {
        executeCallCount += 1
        lastIdReceived = id
        lastNameReceived = newName
        if let errorToThrow { throw errorToThrow }
    }
}

final class MockDeleteReadingListUseCase: DeleteReadingListUseCaseProtocol {
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastIdReceived: UUID?

    func execute(id: UUID) async throws {
        executeCallCount += 1
        lastIdReceived = id
        if let errorToThrow { throw errorToThrow }
    }
}
