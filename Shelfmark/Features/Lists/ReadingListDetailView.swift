//
//  ReadingListDetailView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import SwiftUI
import Observation

struct ReadingListDetailView: View {
    @Bindable var viewModel: ReadingListDetailViewModel
    let container: AppDIContainer

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(_, let books):
                if books.isEmpty {
                    ContentUnavailableView(
                        "Sin libros",
                        systemImage: "book.closed",
                        description: Text("Añade libros con el botón de la barra.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(books, id: \.id) { book in
                            LibraryCellView(book: book)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .contextMenu {
                                    Button("Quitar de la lista", role: .destructive) {
                                        Task { await viewModel.removeBook(bookId: book.id) }
                                    }
                                }
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
        .navigationTitle(viewModel.loadedListName ?? "Lista")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Añadir libros") {
                    viewModel.isPresentingAddBooksSheet = true
                }
                .disabled(viewModel.loadedListName == nil)
            }
        }
        .sheet(isPresented: $viewModel.isPresentingAddBooksSheet) {
            AddBooksToListSheet(
                fetchLibraryUseCase: container.fetchLibraryUseCase,
                bookIdsAlreadyInList: viewModel.bookIdsInList,
                onAddBook: { bookId in await viewModel.addBook(bookId: bookId) },
                onDismiss: { viewModel.isPresentingAddBooksSheet = false }
            )
        }
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Previews

#Preview("Detalle con libros") {
    let listId = UUID()
    let list = ReadingList(id: listId, name: "Lecturas 2026", createdAt: Date(), iconName: "", notes: "")
    let books = [
        Book(
            id: UUID(),
            isbn: "978-84-206-4750-0",
            authors: [Author(id: UUID(), name: "J.R.R. Tolkien")],
            title: "El Hobbit",
            numberOfPages: 366,
            publisher: Publisher(id: UUID(), name: "Minotauro"),
            publicationDate: Date(),
            thumbnailURL: nil,
            bookDescription: nil,
            subtitle: nil,
            language: "es",
            isFavorite: false,
            readingStatus: .none
        ),
    ]
    let vm = ReadingListDetailViewModel(
        listId: listId,
        fetchBooksInListUseCase: PreviewFetchBooksInList(books: books),
        fetchReadingListByIdUseCase: PreviewFetchListById(list: list),
        addBookToReadingListUseCase: PreviewAddBookToList(),
        removeBookFromReadingListUseCase: PreviewRemoveBookFromList()
    )
    Task { await vm.load() }
    return NavigationStack {
        ReadingListDetailView(viewModel: vm, container: AppDIContainer())
    }
}

private struct PreviewFetchBooksInList: FetchBooksInListUseCaseProtocol {
    let books: [Book]
    func execute(listId: UUID) async throws -> [Book] { books }
}

private struct PreviewFetchListById: FetchReadingListByIdUseCaseProtocol {
    let list: ReadingList?
    func execute(listId: UUID) async throws -> ReadingList? { list }
}

private struct PreviewAddBookToList: AddBookToReadingListUseCaseProtocol {
    func execute(bookId: UUID, listId: UUID) async throws {}
}

private struct PreviewRemoveBookFromList: RemoveBookFromReadingListUseCaseProtocol {
    func execute(bookId: UUID, listId: UUID) async throws {}
}
