//
//  FetchLibraryUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

protocol FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book]
}
