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

    private var readingStatusLabel: String? {
        switch book.readingStatus {
        case .none: return nil
        default: return book.readingStatus.displayName
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Portada
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))

                if let url = book.thumbnailURL {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                                .tint(.secondary)
                        }
                        .setProcessor(DownsamplingImageProcessor(size: Self.thumbnailSize))
                        .cancelOnDisappear(true)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)

            // Título, autor y estado
            VStack(spacing: 4) {
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

                if let status = readingStatusLabel {
                    Text(status)
                        .font(.caption2.weight(.medium))
                        .textCase(.uppercase)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.12))
                        )
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

// Preview de ejemplo
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
        readingStatus: .reading,
        currentPage: nil
    )
}

#Preview {
    LibraryCellView(book: Sample.book)
}
