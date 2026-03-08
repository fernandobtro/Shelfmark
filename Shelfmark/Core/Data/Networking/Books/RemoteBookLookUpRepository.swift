//
//  RemoteBookLookUpRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//

import Foundation
/*
 Aquí se implementa el protocolo se conecta DATA CON DOMAIN
 */

final class RemoteBookLookUpRepository: BookLookUpByISBNRepositoryProtocol {
    
    private let dataSource: RemoteBookDataSource
    
    init(dataSource: RemoteBookDataSource) {
        self.dataSource = dataSource
    }
    
    func fetch(byISBN isbn: String) async throws -> Book? {
        let response = try await dataSource.fetchBook(byISBN: isbn)
        
        guard let response else {
            return nil
        }
        
        return RemoteBookMapper.map(response: response, isbn: isbn)
    }
}
