//
//  LookUpByISBNUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//

import Foundation

protocol LookUpByISBNUseCaseProtocol {
    func execute(isbn: String) async throws -> Book?
}
