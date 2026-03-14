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
                }
            }
        }
    }
}
