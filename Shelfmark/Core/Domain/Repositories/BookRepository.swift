//
//  BookRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

protocol BookRepositoryProtocol {
    func saveBook() async throws
    func fetchAllBooks() async throws -> [Book]
    func fetchSingleBook() async throws -> Book
    
}
