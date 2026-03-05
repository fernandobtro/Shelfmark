//
//  LibraryView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                ProgressView("Cargando biblioteca…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let books):
                libraryList(books: books)
            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Biblioteca")
        .task {
            await viewModel.loadLibrary()
        }
    }

    private func libraryList(books: [Book]) -> some View {
        Group {
            if books.isEmpty {
                ContentUnavailableView(
                    "Sin libros",
                    systemImage: "book.closed",
                    description: Text("Añade tu primer libro desde el escáner o el formulario.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(books, id: \.id) { book in
                        libraryRow(book: book)
                    }
                    .onDelete(perform: deleteBooks)
                }
            }
        }
    }

    private func libraryRow(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.title)
                .font(.headline)
            if !book.authors.isEmpty {
                Text(book.authors.map(\.name).joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func deleteBooks(at offsets: IndexSet) {
        guard case .loaded(let books) = viewModel.state else { return }
        for index in offsets {
            let book = books[index]
            Task {
                await viewModel.delete(bookId: book.id)
            }
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Reintentar") {
                Task {
                    await viewModel.loadLibrary()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Preview (mocks solo para previsualización)

private struct MockFetchLibraryUseCase: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] {
        [
            Book(
                id: UUID(),
                isbn: "978-0-00-000000-0",
                authors: [Author(id: UUID(), name: "Autor de ejemplo")],
                title: "Libro de ejemplo",
                numberOfPages: 100,
                publisher: nil,
                publicationDate: nil,
                thumbnailURL: nil,
                bookDescription: nil,
                subtitle: nil,
                language: "es"
            )
        ]
    }
}

private struct MockDeleteBookUseCase: DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws {}
}

#Preview {
    struct PreviewWrapper: View {
        @StateObject private var viewModel = LibraryViewModel(
            fetchLibraryUseCase: MockFetchLibraryUseCase(),
            deleteBookUseCase: MockDeleteBookUseCase()
        )
        var body: some View {
            NavigationStack {
                LibraryView(viewModel: viewModel)
            }
        }
    }
    return PreviewWrapper()
}
