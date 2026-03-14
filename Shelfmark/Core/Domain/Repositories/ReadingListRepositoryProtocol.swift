//
//  ReadingListRepositoryProtocol.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol ReadingListRepositoryProtocol {
    func fetchAllLists() async throws -> [ReadingList]
    func createList(name: String) async throws -> ReadingList
    func renameList(id: UUID, name: String) async throws
    func deleteList(id: UUID) async throws
    func fetchBooks(inList id: UUID) async throws -> [Book]
    func addBook(_ bookId: UUID, toList listId: UUID) async throws
    func removeBook(_ bookId: UUID, fromList listID: UUID) async throws
    func fetchList(byId id: UUID) async throws -> ReadingList?
}
