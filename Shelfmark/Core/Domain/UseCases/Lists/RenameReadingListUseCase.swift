//
//  RenameReadingListUseCase.swift
//  Shelfmark
//

import Foundation

protocol RenameReadingListUseCaseProtocol {
    func execute(id: UUID, newName: String) async throws
}
