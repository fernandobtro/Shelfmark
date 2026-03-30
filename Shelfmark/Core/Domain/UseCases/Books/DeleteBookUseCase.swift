//
//  DeleteBookUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Domain use case contract `DeleteBookUseCase`.
//

import Foundation

/// Domain use case contract `DeleteBookUseCase`.
protocol DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws
}
