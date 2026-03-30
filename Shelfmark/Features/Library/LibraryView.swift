//
//  LibraryView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Library tab screen with loading/error states, search, sorting entry points, and paginated grid rendering.
//

import SwiftUI
import Foundation
import Observation

/// Renders the library state machine and routes user actions to `LibraryViewModel`.
struct LibraryView: View {
    @Bindable var viewModel: LibraryViewModel
    var onStatsTap: () -> Void = {}
    @State private var retryTrigger = 0
    @State private var pendingDeleteBookId: UUID?
    @State private var deleteTrigger = 0

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
        .background(Color.theme.mainBackground)
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
                    onStatsTap()
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                }
                .accessibilityIdentifier("library.statsButton")
                .padding(8)
                .background(Circle().fill(Color.theme.secondaryBackground.opacity(0.7)))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isShowingSortMenu = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .padding(8)
                .background(Circle().fill(Color.theme.secondaryBackground.opacity(0.7)))
            }
        }
        .sheet(isPresented: $viewModel.isShowingSortMenu) {
            LibrarySortMenuView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .dismissKeyboardOnTapOutside()
        .task(id: retryTrigger) {
            await viewModel.loadLibrary()
        }
    }

    private var librarySearchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.theme.textPrimary.opacity(0.5))
            TextField("Buscar por título o autor", text: $viewModel.searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.theme.secondaryBackground.opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func libraryContent() -> some View {
        if viewModel.sectionedBooks.isEmpty {
            let hasActiveSearch = !viewModel.searchText
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
            let hasActiveFilter = viewModel.filterOption != .none
            let isFiltering = hasActiveSearch || hasActiveFilter

            VStack(spacing: 12) {
                ContentUnavailableView(
                    isFiltering ? "Sin resultados" : "Sin libros",
                    systemImage: isFiltering ? "magnifyingglass" : "book.closed",
                    description: Text(
                        isFiltering
                        ? "Prueba con otra búsqueda o limpia los filtros."
                        : "Añade tu primer libro desde el escáner o el formulario."
                    )
                )
                if isFiltering {
                    Button("Limpiar búsqueda y filtros") {
                        viewModel.searchText = ""
                        viewModel.selectFilter(.none)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            LibraryGridView(
                sections: viewModel.sectionedBooks,
                onDelete: { bookId in
                    pendingDeleteBookId = bookId
                    deleteTrigger += 1
                },
                hasMore: viewModel.hasMore,
                isLoadingNextPage: viewModel.isLoadingNextPage,
                onLoadMore: { await viewModel.loadNextPage() },
                minimumColumnWidth: viewModel.libraryGridLayoutOption.minimumColumnWidth
            )
            .task(id: deleteTrigger) {
                if deleteTrigger > 0, let id = pendingDeleteBookId {
                    await viewModel.delete(bookId: id)
                    pendingDeleteBookId = nil
                }
            }
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
            Button("Reintentar") {
                retryTrigger += 1
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("Con libros") {
    let mockFetch = PreviewLibraryFetchUseCase()
    let mockDelete = PreviewLibraryDeleteUseCase()
    let vm = LibraryViewModel(
        fetchLibraryUseCase: mockFetch,
        deleteBookUseCase: mockDelete,
        userProfileRepository: UserDefaultsUserProfileRepository()
    )
    return NavigationStack {
        LibraryView(viewModel: vm)
            .task { await vm.loadLibrary() }
    }
}

#Preview("Sin libros") {
    let mockFetch = PreviewLibraryFetchUseCase(books: [])
    let mockDelete = PreviewLibraryDeleteUseCase()
    let vm = LibraryViewModel(
        fetchLibraryUseCase: mockFetch,
        deleteBookUseCase: mockDelete,
        userProfileRepository: UserDefaultsUserProfileRepository()
    )
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


