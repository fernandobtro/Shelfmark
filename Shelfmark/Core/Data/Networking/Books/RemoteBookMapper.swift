//
//  RemoteBookMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//

import Foundation
/*
 Aquí se hace el mapeo por si hay algo raro 
 */
struct RemoteBookMapper {
    static func map(response: RemoteResponseDTO, isbn: String) -> Book? {
        guard let volumeInfo = response.items?.first?.volumeInfo else {
            return nil
        }
        
        let authors = volumeInfo.authors?.map {
            Author(id: UUID(), name: $0)
        } ?? []
        
        let publisher: Publisher? = volumeInfo.publisher.map {
            Publisher(id: UUID(), name: $0)
        }
        
        // Google Books suele devolver thumbnails con esquema http:// que App Transport Security bloquea.
        // Normalizamos a https:// para que AsyncImage pueda cargarlas sin excepciones en Info.plist.
        let thumbnailStringRaw = volumeInfo.imageLinks?.thumbnail ?? volumeInfo.imageLinks?.smallThumbnail
        let thumbnailString = thumbnailStringRaw.map { url -> String in
            if url.hasPrefix("http://") {
                return "https://" + url.dropFirst("http://".count)
            } else {
                return url
            }
        }
        let thumbnailURL = thumbnailString.flatMap { URL(string: $0) }
        
        let publicationDate = Self.parsePublicationDate(volumeInfo.publishedDate)
        
        return Book(
            id: UUID(),
            isbn: isbn,
            authors: authors,
            title: volumeInfo.title ?? "Unknown Title",
            numberOfPages: volumeInfo.pageCount,
            publisher: publisher,
            publicationDate: publicationDate,
            thumbnailURL: thumbnailURL,
            bookDescription: volumeInfo.description,
            subtitle: volumeInfo.subtitle,
            language: volumeInfo.language ?? "Unknown",
            isFavorite: false,
            readingStatus: .none,
            currentPage: nil
        )
    }
    
    /// Parsea el string de fecha de la API (p. ej. "2020", "2020-01", "2020-01-15") a Date.
    private static func parsePublicationDate(_ string: String?) -> Date? {
        guard let string = string?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty else {
            return nil
        }
        // La API puede devolver solo año, año-mes o año-mes-día
        let padded: String
        if string.count == 4 {
            padded = "\(string)-01-01"
        } else if string.count == 7 {
            padded = "\(string)-01"
        } else {
            padded = string
        }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: padded)
    }
}
