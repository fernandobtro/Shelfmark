//
//  SelectBookForQuoteSheetView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Sheet picker for selecting a target book before saving a quote.
//

import SwiftUI

/// Lists candidate books grouped for fast selection in quote creation flow.
/// Designed to be pushed via `navigationDestination`; uses `@Environment(\.dismiss)` to pop back.
struct SelectBookForQuoteSheetView: View {
    let books: [Book]
    let preselectedBookId: UUID?
    let onSelect: (Book) -> Void
    let onClose: () -> Void

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
        Group {
            if filteredBooks.isEmpty {
                emptyStateView
            } else {
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
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .background(Color.theme.mainBackground)
        .navigationTitle("Seleccionar libro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar") {
                    onClose()
                }
                .accessibilityIdentifier("quote.bookPicker.close")
            }
        }
        .searchable(text: $searchText, prompt: "Buscar en tu biblioteca")
        .dismissKeyboardOnTapOutside()
        .accessibilityIdentifier("quote.bookPicker.screen")
        .onAppear {
            NSLog("[Shelfmark][BookPicker] onAppear | books.count=%d", books.count)
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        let isSearching = !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        VStack(spacing: 12) {
            ContentUnavailableView(
                isSearching ? "Sin resultados" : "Sin libros",
                systemImage: isSearching ? "magnifyingglass" : "book.closed",
                description: Text(
                    isSearching
                    ? "Prueba con otra búsqueda."
                    : "Añade libros en Biblioteca para poder asociarlos a una cita."
                )
            )
            if isSearching {
                Button("Limpiar búsqueda") {
                    searchText = ""
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func bookRow(_ book: Book) -> some View {
        Button {
            onSelect(book)
            onClose()
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
        .buttonStyle(.plain)
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
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .accessibilityLabel(book.title)
        .accessibilityIdentifier("quote.bookPicker.\(book.id.uuidString)")
    }
}

