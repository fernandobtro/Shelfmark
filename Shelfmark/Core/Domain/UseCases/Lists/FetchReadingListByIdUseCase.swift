//
//  FetchReadingListByIdUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol FetchReadingListByIdUseCaseProtocol {
    func execute(listId: UUID) async throws -> ReadingList?
}
