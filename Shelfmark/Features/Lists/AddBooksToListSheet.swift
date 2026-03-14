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

    private var booksToShow: [Book] {
        guard case .loaded(let books) = sheetState else { return [] }
        return books.filter { !bookIdsAlreadyInList.contains($0.id) }
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
                                    Task {
                                        await onAddBook(book.id)
                                    }
                                } label: {
                                    LibraryCellView(book: book)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
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
