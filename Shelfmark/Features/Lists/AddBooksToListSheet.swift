//
//  AddBooksToListSheet.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import SwiftUI

struct AddBooksToListSheet: View {
    let fetchLibraryUseCase: FetchLibraryUseCaseProtocol
    let bookIdsAlreadyInList: Set<UUID>
    let onAddBook: (UUID) async -> Void
    let onDismiss: () -> Void

    enum SheetState {
        case loading
        case loaded([Book])
        case error(String)
    }

    @State private var sheetState: SheetState = .loading
    @State private var searchText: String = ""
    @State private var addTrigger = 0
    @State private var bookIdToAdd: UUID?

    private var booksToShow: [Book] {
        guard case .loaded(let books) = sheetState else { return [] }
        let available = books.filter { !bookIdsAlreadyInList.contains($0.id) }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return available }
        let normalized = query.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current)
        return available.filter { book in
            book.title.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(normalized)
            || book.authors.contains { $0.name.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(normalized) }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch sheetState {
                case .loading:
                    ProgressView("Cargando biblioteca…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded:
                    if booksToShow.isEmpty {
                        ContentUnavailableView(
                            "Nada que añadir",
                            systemImage: "checkmark.circle",
                            description: Text("Todos los libros de tu biblioteca ya están en esta lista.")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(booksToShow, id: \.id) { book in
                                Button {
                                    bookIdToAdd = book.id
                                    addTrigger += 1
                                } label: {
                                    LibraryCellView(book: book)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                        .scrollDismissesKeyboard(.interactively)
                        .task(id: addTrigger) {
                            if addTrigger > 0, let id = bookIdToAdd {
                                await onAddBook(id)
                                await MainActor.run { bookIdToAdd = nil }
                            }
                        }
                    }

                case .error(let message):
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Añadir a la lista")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar por título o autor")
            .dismissKeyboardOnTapOutside()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        onDismiss()
                    }
                }
            }
            .task {
                await loadLibrary()
            }
        }
    }

    private func loadLibrary() async {
        sheetState = .loading
        do {
            let books = try await fetchLibraryUseCase.execute()
            await MainActor.run {
                sheetState = .loaded(books)
            }
        } catch {
            await MainActor.run {
                sheetState = .error(error.localizedDescription)
            }
        }
    }
}

// MARK: - Preview

#Preview("Añadir libros (con datos mock)") {
    AddBooksToListSheet(
        fetchLibraryUseCase: PreviewAddBooksFetchUseCase(),
        bookIdsAlreadyInList: [],
        onAddBook: { _ in },
        onDismiss: {}
    )
}

private struct PreviewAddBooksFetchUseCase: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { PreviewHelpers.previewBooks }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] {
        Array(PreviewHelpers.previewBooks.dropFirst(offset).prefix(limit))
    }
}
