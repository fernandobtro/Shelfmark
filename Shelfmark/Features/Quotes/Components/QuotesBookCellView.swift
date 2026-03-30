//
//  QuotesBookCellView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Quotes-by-book grid/list cell with cover, title, and quote count badge.
//

import SwiftUI
import Kingfisher

/// Renders one grouped book item in the Quotes By Book representation.
struct QuotesBookCellView: View {
    let book: Book
    let quoteCount: Int

    private static let thumbnailSize = CGSize(width: 200, height: 300)

    private var authorsText: String {
        book.authors.map(\.name).joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.theme.secondaryBackground.opacity(0.72))

                if let url = book.thumbnailURL {
                    KFImage(url)
                        .placeholder { ProgressView().tint(.secondary) }
                        .setProcessor(DownsamplingImageProcessor(size: Self.thumbnailSize))
                        .cancelOnDisappear(true)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 4)

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
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.secondaryBackground.opacity(0.4))
        )
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
