//
//  LibraryView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI
import Foundation

struct LibraryView: View {
    
    // El ViewModel viene inyectado desde fuera.
    // ObservedObject porque la vista NO lo crea,
    // solo observa cambios publicados.
    @ObservedObject var viewModel: LibraryViewModel

    var body: some View {
        Group {
            switch viewModel.state {

            case .idle:
                // Estado inicial antes de cargar.
                Color.clear

            case .loading:
                // Indicador de carga mientras fetchLibraryUseCase corre.
                ProgressView("Cargando biblioteca…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                // Ya NO usamos directamente "books".
                // Porque el ViewModel ya expone:
                // viewModel.sectionedBooks
                // que incluye:
                // filtro + orden + agrupación
                libraryContent()

            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Biblioteca")

        // HEADER con filtros
        // Aquí ponemos LibraryHeaderView
        .safeAreaInset(edge: .top) {
            LibraryHeaderView(viewModel: viewModel)
        }

        // BOTÓN DE ORDENAR
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isShowingSortMenu = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }

        // SHEET con menú de orden
        .sheet(isPresented: $viewModel.isShowingSortMenu) {
            LibrarySortMenuView(viewModel: viewModel)
        }

        // Carga inicial
        .task {
            await viewModel.loadLibrary()
        }
    }

    // MARK: - Contenido principal de la biblioteca
    
    @ViewBuilder
    private func libraryContent() -> some View {

            // Si no hay libros después de aplicar filtros
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

                // Vista real de la biblioteca
                // Recibe secciones ya preparadas por el ViewModel
                LibraryGridView(
                    sections: viewModel.sectionedBooks,
                    onDelete: { bookId in
                        Task { await viewModel.delete(bookId: bookId) }
                    }
                )

            }
    }

    // MARK: - Error

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
                language: "es",
                isFavorite: false,
                readingStatus: .none
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
