//
//  LibraryGridView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import SwiftUI

struct LibraryGridView: View {
    let sections: [LibrarySection]
    let onDelete: (UUID) -> Void
    let hasMore: Bool
    let isLoadingNextPage: Bool
    let onLoadMore: () async -> Void

    // Grid adaptable: ajusta el número de columnas según el ancho disponible.
    // Mínimo ~140pt por celda para mantener una portada legible.
    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]

    var body: some View {
        if sections.isEmpty {
            EmptyView()
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {

                    ForEach(sections) { section in

                        if sections.count > 1 {
                            Text(section.categoryName)
                                .font(.headline)
                                .padding(.horizontal, 20)
                        }

                        LazyVGrid(columns: columns, alignment: .center, spacing: 24) {

                            ForEach(section.books, id: \.id) { book in
                                NavigationLink(value: book.id) {
                                    LibraryCellView(book: book)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Eliminar", role: .destructive) {
                                        onDelete(book.id)
                                    }
                                }
                            }

                        }
                        .padding(.horizontal, 20)
                    }

                    if hasMore {
                        if isLoadingNextPage {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .padding()
                        } else {
                            Color.clear
                                .frame(height: 1)
                                .task { await onLoadMore() }
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Preview

#Preview {
    let section = LibrarySection(categoryName: "Todos", books: PreviewHelpers.previewBooks)
    return NavigationStack {
        LibraryGridView(
            sections: [section],
            onDelete: { _ in },
            hasMore: false,
            isLoadingNextPage: false,
            onLoadMore: { }
        )
    }
}
