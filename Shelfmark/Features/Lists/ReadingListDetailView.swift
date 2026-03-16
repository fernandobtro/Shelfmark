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
    @State private var pendingRemoveBookId: UUID?
    @State private var removeTrigger = 0

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let list, let books):
                ScrollView {
                    VStack(spacing: 24) {
                        heroHeader(list: list, books: books)

                        if books.isEmpty {
                            emptyStateCTA()
                        } else {
                            booksSection(books)
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
        .background(Color.theme.mainBackground)
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
        .task(id: removeTrigger) {
            if removeTrigger > 0, let id = pendingRemoveBookId {
                await viewModel.removeBook(bookId: id)
                pendingRemoveBookId = nil
            }
        }
    }

    // MARK: - Secciones

    private func heroHeader(list: ReadingList, books: [Book]) -> some View {
        VStack(spacing: 16) {
            // Mosaico 2x2 de portadas
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.theme.secondaryBackground)
                    .frame(width: 100, height: 100)

                let covers = books.compactMap(\.thumbnailURL).prefix(4)
                if covers.isEmpty {
                    Image(systemName: list.iconName?.isEmpty == false ? list.iconName! : "text.book.closed.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.primaryGreen)
                } else {
                    let urls = Array(covers)
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            heroThumbnail(for: indexOrNil(urls, 0))
                            heroThumbnail(for: indexOrNil(urls, 1))
                        }
                        HStack(spacing: 2) {
                            heroThumbnail(for: indexOrNil(urls, 2))
                            heroThumbnail(for: indexOrNil(urls, 3))
                        }
                    }
                    .padding(6)
                }
            }

            VStack(spacing: 6) {
                Text(list.name)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                let count = books.count
                let countText = count == 1 ? "1 libro" : "\(count) libros"
                let dateText = list.createdAt.formatted(date: .abbreviated, time: .omitted)
                Text("\(countText) • \(dateText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
        }
        .padding(.top, 24)
    }

    private func emptyStateCTA() -> some View {
        VStack(spacing: 16) {
            Text("Sin libros en esta lista")
                .font(.headline)

            Text("Añade libros desde tu biblioteca para empezar a llenarla.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                viewModel.isPresentingAddBooksSheet = true
            } label: {
                Text("Añadir mis primeros libros")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.primaryGreen)
        }
        .padding(.horizontal)
        .padding(.vertical, 32)
    }

    private func booksSection(_ books: [Book]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(books, id: \.id) { book in
                LibraryCellView(book: book)
                    .contextMenu {
                        Button("Quitar de la lista", role: .destructive) {
                            pendingRemoveBookId = book.id
                            removeTrigger += 1
                        }
                    }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func heroThumbnail(for url: URL?) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.theme.mainBackground.opacity(0.6))

            if let url {
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
    return NavigationStack {
        ReadingListDetailView(viewModel: vm, container: AppDIContainer())
            .task { await vm.load() }
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
