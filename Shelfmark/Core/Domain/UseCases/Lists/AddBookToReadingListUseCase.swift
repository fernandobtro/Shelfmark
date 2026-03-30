//
//  AddBookToReadingListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `AddBookToReadingListUseCase`.
//

import Foundation

/// Domain use case contract `AddBookToReadingListUseCase`.
protocol AddBookToReadingListUseCaseProtocol {
    func execute(bookId: UUID, listId: UUID) async throws
}
