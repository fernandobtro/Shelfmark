//  Purpose: Reading list row view with cover mosaic preview, title, and item count badge.
//
import SwiftUI

/// Renders one list card with summary metadata and preview covers.
struct ReadingListCellView: View {
    let list: ReadingList
    /// Number of books in the list, provided by the view model.
    let booksCount: Int
    /// Sample cover URLs (up to 4). Can be empty.
    let previewCoverURLs: [URL]

    private var formattedDate: String {
        list.createdAt.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Mini cover mosaic or placeholder icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.theme.secondaryBackground)
                    .frame(width: 56, height: 56)

                if previewCoverURLs.isEmpty {
                    Image(systemName: list.iconName?.isEmpty == false ? list.iconName! : "text.book.closed.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primaryGreen)
                } else {
                    let covers = Array(previewCoverURLs.prefix(4))
                    // 2x2 thumbnail grid
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            coverThumbnail(for: indexOrNil(covers, 0))
                            coverThumbnail(for: indexOrNil(covers, 1))
                        }
                        HStack(spacing: 2) {
                            coverThumbnail(for: indexOrNil(covers, 2))
                            coverThumbnail(for: indexOrNil(covers, 3))
                        }
                    }
                    .padding(4)
                }
            }

            // Información principal
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.headline)
                    .foregroundStyle(Color.theme.textPrimary)
                    .lineLimit(1)

                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Badge showing book count
            if booksCount > 0 {
                Text("\(booksCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.theme.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color.theme.secondaryBackground.opacity(0.9))
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.theme.secondaryBackground.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func coverThumbnail(for url: URL?) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.theme.mainBackground.opacity(0.6))

            if let url {
                // `AsyncImage` keeps this cell independent from Kingfisher.
                // Optimized image loading is already handled in `LibraryCellView`.
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.clear
                }
            }
        }
        .clipped()
    }

    private func indexOrNil(_ array: [URL], _ index: Int) -> URL? {
        guard array.indices.contains(index) else { return nil }
        return array[index]
    }
}

#Preview {
    ReadingListCellView(
        list: ReadingList(
            id: UUID(),
            name: "Libros para leer en 2026",
            createdAt: Date(),
            iconName: nil,
            notes: "Notas opcionales"
        ),
        booksCount: 7,
        previewCoverURLs: []
    )
}

