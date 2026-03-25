//
//  QuotesBookCellView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI
import Kingfisher

/// Celda de libro para la vista "Por libro" en Citas: portada, título, autor y badge con número de citas.
struct QuotesBookCellView: View {
    let book: Book
    let quoteCount: Int

    private static let thumbnailSize = CGSize(width: 200, height: 300)

    private var authorsText: String {
        book.authors.map(\.name).joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))

                if let url = book.thumbnailURL {
                    KFImage(url)
                        .placeholder { ProgressView().tint(.secondary) }
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

                Text("\(quoteCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.theme.primaryGreen))
                    .padding(8)
            }
            .aspectRatio(2/3, contentMode: .fit)
            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)

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
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
