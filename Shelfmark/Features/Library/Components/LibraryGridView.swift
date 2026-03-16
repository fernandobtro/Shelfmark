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
    let onLoadMore: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible())
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
                                .padding(.horizontal, 16)
                        }

                        LazyVGrid(columns: columns, spacing: 20) {

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
                        .padding(.horizontal, 16)
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
                                .onAppear { onLoadMore() }
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
            onLoadMore: {}
        )
    }
}
