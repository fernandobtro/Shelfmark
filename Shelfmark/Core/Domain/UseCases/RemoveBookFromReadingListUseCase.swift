//
//  RemoveBookFromReadingListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol RemoveBookFromReadingListUseCaseProtocol {
    func execute(bookId: UUID, listId: UUID) async throws
}
