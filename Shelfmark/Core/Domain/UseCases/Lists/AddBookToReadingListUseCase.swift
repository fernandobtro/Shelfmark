//
//  AddBookToReadingListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol AddBookToReadingListUseCaseProtocol {
    func execute(bookId: UUID, listId: UUID) async throws
}
