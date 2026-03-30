//
//  BookLookUpByISBNRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//
//  Purpose: Repository boundary `BookLookUpByISBNRepository`.
//

import Foundation

/// Repository boundary `BookLookUpByISBNRepository`.
protocol BookLookUpByISBNRepositoryProtocol {
    func fetch(byISBN: String) async throws -> Book?
}
