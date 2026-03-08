//
//  BookLookUpByISBNRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//

import Foundation

protocol BookLookUpByISBNRepositoryProtocol {
    func fetch(byISBN: String) async throws -> Book?
}
