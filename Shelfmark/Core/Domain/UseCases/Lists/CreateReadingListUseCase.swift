//
//  CreateReadingListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol CreateReadingListUseCaseProtocol {
    func execute(name: String) async throws -> ReadingList
}
