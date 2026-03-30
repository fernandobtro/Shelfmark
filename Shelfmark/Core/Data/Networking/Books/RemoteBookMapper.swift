//
//  RemoteBookMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 06/03/26.
//
//  Purpose: Mapper that converts Google Books payloads into domain `Book` values.
//

import Foundation

/// Transforms remote DTO metadata into normalized Shelfmark domain models.
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
        
        // Google Books may return `http://` thumbnails blocked by App Transport Security.
        // Normalize to `https://` so `AsyncImage` can load them without ATS exceptions.
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
    
    /// Parses API date strings (for example `2020`, `2020-01`, `2020-01-15`) into `Date`.
    private static func parsePublicationDate(_ string: String?) -> Date? {
        guard let string = string?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty else {
            return nil
        }
        // API can return year-only, year-month, or full year-month-day values.
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
