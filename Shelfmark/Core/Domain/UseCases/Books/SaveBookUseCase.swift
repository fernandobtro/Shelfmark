//
//  SaveBookUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

protocol SaveBookUseCaseProtocol {
    func execute(_ book: Book) async throws
}
