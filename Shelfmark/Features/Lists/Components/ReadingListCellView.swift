import SwiftUI

struct ReadingListCellView: View {
    let list: ReadingList
    /// Número de libros en la lista, proporcionado por el ViewModel.
    let booksCount: Int
    /// URLs de portada de ejemplo (hasta 4). Puede venir vacío.
    let previewCoverURLs: [URL]

    private var formattedDate: String {
        list.createdAt.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Mini mosaico de portadas o icono de placeholder
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
                    // Grid 2x2 de miniaturas
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

            // Badge con contador de libros
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
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func coverThumbnail(for url: URL?) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.theme.mainBackground.opacity(0.6))

            if let url {
                // Usamos AsyncImage aquí para evitar acoplar Kingfisher a esta celda;
                // la carga optimizada ya está en LibraryCellView.
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

