//
//  BookRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

protocol BookRepositoryProtocol {
    func save(_ book: Book) async throws
    func fetchAll() async throws -> [Book]
    func fetchPaginated(limit: Int, offset: Int) async throws -> [Book]
    func fetchBook(by id: UUID) async throws -> Book?
    func fetchBooks(byAuthorId id: UUID) async throws -> [Book]
    func fetchBooks(byPublisherId id: UUID) async throws -> [Book]
    func delete(by bookId: UUID) async throws
}
