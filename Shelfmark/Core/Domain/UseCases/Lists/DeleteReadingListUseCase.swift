//
//  DeleteReadingListUseCase.swift
//  Shelfmark
//

import Foundation

protocol DeleteReadingListUseCaseProtocol {
    func execute(id: UUID) async throws
}
