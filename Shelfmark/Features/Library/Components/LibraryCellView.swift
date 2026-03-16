//
//  LibraryCellView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import SwiftUI
import Kingfisher

struct LibraryCellView: View {
    let book: Book

    /// Tamaño de miniatura para caché y downsampling (evita retener imágenes a resolución completa).
    private static let thumbnailSize = CGSize(width: 200, height: 300)

    private var authorsText: String {
        book.authors.map(\.name).joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Portada: pipeline imagen separado (URL → Kingfisher → caché → vista)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))

                if let url = book.thumbnailURL {
                    KFImage(url)
                        .placeholder { ProgressView() }
                        .setProcessor(DownsamplingImageProcessor(size: Self.thumbnailSize))
                        .cancelOnDisappear(true)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            // Título y autor centrados, con altura fija para que todas las celdas tengan la misma altura
            VStack(spacing: 2) {
                Text(book.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if !authorsText.isEmpty {
                    Text(authorsText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .top)
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


