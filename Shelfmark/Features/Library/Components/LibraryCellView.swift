//
//  LibraryCellView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import SwiftUI

// MARK: - Instrucciones (qué hace esta celda)
// 1. Esta vista representa UNA tarjeta de libro como en el mock: portada arriba, título y autor debajo.
// 2. La idea es que LibraryGridView cree muchas LibraryCellView(book:) dentro de un LazyVGrid para formar el grid.
// 3. Si quieres ajustar el estilo (tamaños de letra, sombras, colores), hazlo solo aquí; el grid no debería saber de diseño de la tarjeta.

struct LibraryCellView: View {
    let book: Book

    private var authorsText: String {
        book.authors.map(\.name).joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Portada
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))

                if let url = book.thumbnailURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "book.closed")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(2/3, contentMode: .fit) // relación de portada de libro
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            // Título
            Text(book.title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Autor(es)
            if !authorsText.isEmpty {
                Text(authorsText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

private struct Sample {
    static let book = Book(
        id: UUID(),
        isbn: "978-84-206-4750-0",
        authors: [Author(id: UUID(), name: "J.R.R. Tolkien")],
        title: "El Hobbit",
        numberOfPages: 366,
        publisher: Publisher(id: UUID(), name: "Minotauro"),
        publicationDate: Date(),
        thumbnailURL: nil,
        bookDescription: "Un clásico de la fantasía.",
        subtitle: "O ida y vuelta",
        language: "es",
        isFavorite: false,
        readingStatus: .none
    )
}

#Preview {
    LibraryCellView(book: Sample.book)
}


