//
//  LibraryView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI
import Foundation
import Observation

struct LibraryView: View {
    
    @Bindable var viewModel: LibraryViewModel

    var body: some View {
        Group {
            switch viewModel.state {

            case .idle:
                Color.clear

            case .loading:
                ProgressView("Cargando biblioteca…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                libraryContent()

            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Mi Biblioteca")
        .safeAreaInset(edge: .top) {
            VStack(spacing: 12) {
                LibraryHeaderView(viewModel: viewModel)
                if case .loaded = viewModel.state {
                    librarySearchBar
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isShowingSortMenu = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingSortMenu) {
            LibrarySortMenuView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .dismissKeyboardOnTapOutside()
        .task {
            await viewModel.loadLibrary()
        }
    }

    private var librarySearchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Buscar por título o autor", text: $viewModel.searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(.bar)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func libraryContent() -> some View {
        if viewModel.sectionedBooks.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "book.closed")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Text("Sin libros")
                    .font(.headline)

                Text("Añade tu primer libro desde el escáner o el formulario.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            LibraryGridView(
                sections: viewModel.sectionedBooks,
                onDelete: { bookId in
                    Task { await viewModel.delete(bookId: bookId) }
                },
                hasMore: viewModel.hasMore,
                isLoadingNextPage: viewModel.isLoadingNextPage,
                onLoadMore: { Task { await viewModel.loadNextPage() } }
            )
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Previews

#Preview("Con libros") {
    let mockFetch = PreviewLibraryFetchUseCase()
    let mockDelete = PreviewLibraryDeleteUseCase()
    let vm = LibraryViewModel(fetchLibraryUseCase: mockFetch, deleteBookUseCase: mockDelete)
    return NavigationStack {
        LibraryView(viewModel: vm)
            .task { await vm.loadLibrary() }
    }
}

#Preview("Sin libros") {
    let mockFetch = PreviewLibraryFetchUseCase(books: [])
    let mockDelete = PreviewLibraryDeleteUseCase()
    let vm = LibraryViewModel(fetchLibraryUseCase: mockFetch, deleteBookUseCase: mockDelete)
    return NavigationStack {
        LibraryView(viewModel: vm)
            .task { await vm.loadLibrary() }
    }
}

private struct PreviewLibraryFetchUseCase: FetchLibraryUseCaseProtocol {
    let books: [Book]
    init(books: [Book] = PreviewHelpers.previewBooks) { self.books = books }
    func execute() async throws -> [Book] { books }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] {
        Array(books.dropFirst(offset).prefix(limit))
    }
}

private struct PreviewLibraryDeleteUseCase: DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws {}
}


