//
//  MockReadingListRepository.swift
//  ShelfmarKTests
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Shelfmark component `MockReadingListRepository`.
//

import Foundation
@testable import Shelfmark

/// Shelfmark component `MockReadingListRepository`.
final class MockReadingListRepository: ReadingListRepositoryProtocol {
    // MARK: - Configurable results

    var fetchAllListsResult: [ReadingList] = []
    var fetchListByIdResult: ReadingList?
    var fetchBooksInListResult: [Book] = []
    var errorToThrow: Error?

    // MARK: - Call tracking

    var fetchAllCallCount = 0
    var fetchListByIdCallCount = 0

    var createListCalls: [String] = []
    var renameListCalls: [(id: UUID, name: String)] = []
    var deleteListCalls: [UUID] = []

    var fetchBooksCalls: [UUID] = []

    var addBookCalls: [(bookId: UUID, listId: UUID)] = []
    var removeBookCalls: [(bookId: UUID, listId: UUID)] = []
    
    
    func fetchAllLists() async throws -> [Shelfmark.ReadingList] {
        fetchAllCallCount += 1
        
        if let error = errorToThrow {
            throw error
        }

        return fetchAllListsResult
        
    }

    func fetchListsPaginated(limit: Int, offset: Int) async throws -> [ReadingList] {
        fetchAllCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return Array(fetchAllListsResult.dropFirst(offset).prefix(limit))
    }
    
    func createList(name: String) async throws -> Shelfmark.ReadingList {
        createListCalls.append(name)

        if let error = errorToThrow {
            throw error
        }

        return ReadingList(
            id: UUID(),
            name: name,
            createdAt: Date(),
            iconName: nil,
            notes: nil
        )
    }
    
    func renameList(id: UUID, name: String) async throws {
        renameListCalls.append((id: id, name: name))

        if let error = errorToThrow {
            throw error
        }
    }
    
    func deleteList(id: UUID) async throws {
        deleteListCalls.append(id)

        if let error = errorToThrow {
            throw error
        }
    }
    
    func fetchBooks(inList id: UUID) async throws -> [Shelfmark.Book] {
        fetchBooksCalls.append(id)

        if let error = errorToThrow {
            throw error
        }

        return fetchBooksInListResult
    }
    
    func addBook(_ bookId: UUID, toList listId: UUID) async throws {
        addBookCalls.append((bookId: bookId, listId: listId))

        if let error = errorToThrow {
            throw error
        }
    }
    
    func removeBook(_ bookId: UUID, fromList listID: UUID) async throws {
        removeBookCalls.append((bookId: bookId, listId: listID))

        if let error = errorToThrow {
            throw error
        }
    }
    
    func fetchList(byId id: UUID) async throws -> Shelfmark.ReadingList? {
        fetchListByIdCallCount += 1

        if let error = errorToThrow {
            throw error
        }

        return fetchListByIdResult
    }
}
