//
//  RemoteBookLookUpRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//
//  Purpose: Repository adapter bridging remote ISBN data source to domain lookup contract.
//

import Foundation

/// Implements book lookup repository reads using remote Google Books responses.
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
