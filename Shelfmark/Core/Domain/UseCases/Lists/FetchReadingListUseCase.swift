//
//  FetchReadingListUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

protocol FetchReadingListUseCaseProtocol {
    func execute() async throws -> [ReadingList]
    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList]
}
