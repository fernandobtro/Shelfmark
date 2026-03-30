//
//  LookUpByISBNUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//
//  Purpose: Domain use case contract `LookUpByISBNUseCase`.
//

import Foundation

/// Domain use case contract `LookUpByISBNUseCase`.
protocol LookUpByISBNUseCaseProtocol {
    func execute(isbn: String) async throws -> Book?
}
