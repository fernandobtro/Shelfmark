//
//  RemoveBookFromReadingListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain use case contract `RemoveBookFromReadingListUseCase`.
//

import Foundation

/// Domain use case contract `RemoveBookFromReadingListUseCase`.
protocol RemoveBookFromReadingListUseCaseProtocol {
    func execute(bookId: UUID, listId: UUID) async throws
}
