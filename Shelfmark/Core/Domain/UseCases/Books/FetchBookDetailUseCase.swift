//
//  FetchBookDetailUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

protocol FetchBookDetailUseCaseProtocol {
    func execute(bookId: UUID) async throws -> Book?
}
