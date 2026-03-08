//
//  RemoteBookDataSource.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//

import Foundation
 /*
  Implementa la llamada HTTP y devuelve un DTO o un tipo intermedio (No tiene por que ser Book aún
  */

final class RemoteBookDataSource {
    private let session: URLSession
    private let apiKey: String
    
    init(session: URLSession, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }
    
    func fetchBook(byISBN isbn: String) async throws -> RemoteResponseDTO? {
        var components = URLComponents(string: "https://www.googleapis.com/books/v1/volumes")
        
        components?.queryItems = [URLQueryItem(name: "q", value: "isbn:\(isbn)"), URLQueryItem(name: "key", value: apiKey)]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await session.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(RemoteResponseDTO.self, from: data)
        
        return response
    }
}
