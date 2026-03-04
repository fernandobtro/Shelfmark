//
//  DeleteBookUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

protocol DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws
}
