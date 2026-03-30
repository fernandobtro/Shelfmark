//
//  SaveBookUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Domain use case contract `SaveBookUseCase`.
//

import Foundation

/// Domain use case contract `SaveBookUseCase`.
protocol SaveBookUseCaseProtocol {
    func execute(_ book: Book) async throws
}
