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
    
    // 3 columnas iguales; spacing entre columnas; la portada mantiene 2:3 dentro de cada celda
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
                LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                    ForEach(sections) { section in
                        if sections.count > 1 {
                            Text(section.categoryName)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }

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
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
