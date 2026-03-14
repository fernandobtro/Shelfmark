//
//  FetchBooksInListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol FetchBooksInListUseCaseProtocol {
    func execute(listId: UUID) async throws -> [Book]
}
