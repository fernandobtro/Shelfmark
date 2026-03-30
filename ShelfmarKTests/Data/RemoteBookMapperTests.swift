//
//  RemoteBookMapperTests.swift
//  ShelfmarKTests
//
//  Example test per category with guidance comments for additional coverage.
//
//  Purpose: Unit tests for `RemoteBookMapperTests`.
//

import XCTest
@testable import Shelfmark

/// Unit tests for `RemoteBookMapperTests`.
@MainActor
final class RemoteBookMapperTests: XCTestCase {

    // MARK: - Implemented Example

    /// With a valid DTO payload (one item with volumeInfo), map returns a `Book` with title, ISBN, and authors.
    func test_map_conDTOValido_devuelveBookConDatosMapeados() throws {
        let json = """
        {
            "items": [{
                "volumeInfo": {
                    "title": "El libro mapeado",
                    "subtitle": "Subtítulo",
                    "authors": ["Autor A", "Autor B"],
                    "publisher": "Editorial X",
                    "publishedDate": "2020-06-15",
                    "description": "Descripción",
                    "pageCount": 200,
                    "language": "es",
                    "imageLinks": { "thumbnail": "https://example.com/cover.jpg" }
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let dto = try JSONDecoder().decode(RemoteResponseDTO.self, from: data)

        let result = RemoteBookMapper.map(response: dto, isbn: "978-1234567890")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "El libro mapeado")
        XCTAssertEqual(result?.subtitle, "Subtítulo")
        XCTAssertEqual(result?.isbn, "978-1234567890")
        XCTAssertEqual(result?.authors.map(\.name), ["Autor A", "Autor B"])
        XCTAssertEqual(result?.publisher?.name, "Editorial X")
        XCTAssertEqual(result?.numberOfPages, 200)
        XCTAssertEqual(result?.language, "es")
        XCTAssertEqual(result?.bookDescription, "Descripción")
    }

    // MARK: - Additional Cases

    func test_map_conItemsVacio_devuelveNil() throws {
        let json = """
        { "items": [] }
        """
        let data = json.data(using: .utf8)!
        let dto = try JSONDecoder().decode(RemoteResponseDTO.self, from: data)

        let result = RemoteBookMapper.map(response: dto, isbn: "123")

        XCTAssertNil(result)
    }

    func test_map_conVolumeInfoSinTitulo_devuelveUnknownTitle() throws {
        let json = """
        {
            "items": [{
                "volumeInfo": {
                    "subtitle": "Sub",
                    "authors": [],
                    "publisher": null,
                    "publishedDate": null,
                    "description": null,
                    "pageCount": null,
                    "language": "es",
                    "imageLinks": null
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let dto = try JSONDecoder().decode(RemoteResponseDTO.self, from: data)

        let result = RemoteBookMapper.map(response: dto, isbn: "123")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Unknown Title")
    }

    func test_map_conPublishedDateSoloAno_parseaCorrectamente() throws {
        let json = """
        {
            "items": [{
                "volumeInfo": {
                    "title": "Con año",
                    "publishedDate": "2020"
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let dto = try JSONDecoder().decode(RemoteResponseDTO.self, from: data)

        let result = RemoteBookMapper.map(response: dto, isbn: "123")

        XCTAssertNotNil(result)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let year = result.flatMap { calendar.dateComponents([.year], from: $0.publicationDate!).year }
        XCTAssertEqual(year, 2020)
    }

    func test_map_conPublishedDateAnoMes_parseaCorrectamente() throws {
        let json = """
        {
            "items": [{
                "volumeInfo": {
                    "title": "Con año y mes",
                    "publishedDate": "2020-06"
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let dto = try JSONDecoder().decode(RemoteResponseDTO.self, from: data)

        let result = RemoteBookMapper.map(response: dto, isbn: "123")

        XCTAssertNotNil(result)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let comps = result.map { calendar.dateComponents([.year, .month], from: $0.publicationDate!) }
        XCTAssertEqual(comps?.year, 2020)
        XCTAssertEqual(comps?.month, 6)
    }

    func test_map_sinAutores_devuelveArrayVacio() throws {
        let json = """
        {
            "items": [{
                "volumeInfo": {
                    "title": "Sin autores",
                    "authors": null
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let dto = try JSONDecoder().decode(RemoteResponseDTO.self, from: data)

        let result = RemoteBookMapper.map(response: dto, isbn: "123")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.authors.count, 0)
    }

    func test_map_sinEditorial_devuelvePublisherNil() throws {
        let json = """
        {
            "items": [{
                "volumeInfo": {
                    "title": "Sin editorial",
                    "publisher": null
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let dto = try JSONDecoder().decode(RemoteResponseDTO.self, from: data)

        let result = RemoteBookMapper.map(response: dto, isbn: "123")

        XCTAssertNotNil(result)
        XCTAssertNil(result?.publisher)
    }
}
