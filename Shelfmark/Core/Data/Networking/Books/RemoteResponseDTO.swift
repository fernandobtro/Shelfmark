//
//  RemoteResponseDTO.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//

import Foundation
/*
 Aquí se hace el decode
 */

struct RemoteResponseDTO: Decodable {
    let items: [VolumeDTO]?
}

struct VolumeDTO: Decodable {
    let volumeInfo: VolumeInfoDTO
}

struct VolumeInfoDTO: Decodable {
    let title: String?
        let subtitle: String?
        let authors: [String]?
        let publisher: String?
        let publishedDate: String?
        let description: String?
        let pageCount: Int?
        let language: String?
        let imageLinks: ImageLinksDTO?
        
    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case authors
        case publisher
        case publishedDate
        case description
        case pageCount
        case language
        case imageLinks
    }
}

struct ImageLinksDTO: Decodable {
    let thumbnail: String?
}
