//
//  SelectBookForQuoteSheetView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI

/// Selector dedicado de libro para una cita, agrupando por estado de lectura.
struct SelectBookForQuoteSheetView: View {
    let books: [Book]
    let preselectedBookId: UUID?
    let onSelect: (Book) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    private var filteredBooks: [Book] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return books }
        let normalized = query.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current)
        return books.filter { book in
            book.title.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(normalized)
            || book.authors.contains { author in
                author.name.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(normalized)
            }
        }
    }

    private var readingNow: [Book] {
        filteredBooks.filter { $0.readingStatus == .reading }
    }

    private var read: [Book] {
        filteredBooks.filter { $0.readingStatus == .read }
    }

    private var others: [Book] {
        filteredBooks.filter { status in
            status.readingStatus != .reading && status.readingStatus != .read
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !readingNow.isEmpty {
                    Section("Leyendo ahora") {
                        ForEach(readingNow, id: \.id) { book in
                            bookRow(book)
                        }
                    }
                }

                if !read.isEmpty {
                    Section("Leídos") {
                        ForEach(read, id: \.id) { book in
                            bookRow(book)
                        }
                    }
                }

                if !others.isEmpty {
                    Section("Resto de la biblioteca") {
                        ForEach(others, id: \.id) { book in
                            bookRow(book)
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar libro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar en tu biblioteca")
        }
    }

    private func bookRow(_ book: Book) -> some View {
        Button {
            onSelect(book)
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.body)
                    let authors = book.authors.map(\.name).joined(separator: ", ")
                    if !authors.isEmpty {
                        Text(authors)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if book.id == preselectedBookId {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

