//
//  LibraryViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation
import Combine

/// Los únicos estados posibles de la pantalla de biblioteca.
/// La pantalla está siempre en uno solo; no puede estar "cargando" y "con datos" a la vez.
enum LibraryState: Equatable {
    /// Aún no se ha pedido la lista.
    case idle
    /// Se está pidiendo la lista al use case.
    case loading
    /// Ya tenemos la lista; el array son los libros a mostrar.
    case loaded([Book])
    /// Algo falló; el String es el mensaje para el usuario.
    case error(String)
}

final class LibraryViewModel: ObservableObject {
    @Published var state: LibraryState = .idle
    @Published var sortOption: SortOption = .title
    @Published var groupOption: GroupOption = .none
    @Published var isShowingSortMenu: Bool = false
    @Published var filterOption: FilterOption = .all
    
    var sectionedBooks: [LibrarySection] {
        guard case .loaded(let books) = state else { return [] }

            let filteredBooks = books.filter { book in
            switch filterOption {
            case .all:
                return true
            case .reading:
                return book.readingStatus == .reading
            case .favorites:
                return book.isFavorite
            }
        }
        

        // (c) Orden
        let sortedBooks = filteredBooks.sorted { book1, book2 in
            switch sortOption {
            case .title:
                return book1.title.localizedCaseInsensitiveCompare(book2.title) == .orderedAscending
            case .author:
                let author1 = book1.authors.first?.name ?? ""
                let author2 = book2.authors.first?.name ?? ""
                return author1.localizedCaseInsensitiveCompare(author2) == .orderedAscending
            }
        }

        // (d) Agrupación
        switch groupOption {
        case .publisher:
            let grouped = Dictionary(grouping: sortedBooks) { book in
                book.publisher?.name ?? "Editorial desconocida"
            }
            return makeSections(from: grouped)
        case .author:
            let grouped = Dictionary(grouping: sortedBooks) { book in
                book.authors.first?.name ?? "Autor desconocido"
            }
            return makeSections(from: grouped)
        case .none:
            return [LibrarySection(categoryName: "Todos", books: sortedBooks)]
        }
    }

    private let fetchLibraryUseCase: FetchLibraryUseCaseProtocol
    private let deleteBookUseCase: DeleteBookUseCaseProtocol

    init(fetchLibraryUseCase: FetchLibraryUseCaseProtocol, deleteBookUseCase: DeleteBookUseCaseProtocol) {
        self.fetchLibraryUseCase = fetchLibraryUseCase
        self.deleteBookUseCase = deleteBookUseCase
    }

    /// Carga la lista de libros. Actualiza `state` a .loading, luego .loaded(books) o .error(mensaje).
    /// Debe llamarse desde la vista (p. ej. en .task { await viewModel.loadLibrary() }).
    func loadLibrary() async {
        state = .loading
        do {
            let books = try await fetchLibraryUseCase.execute()
            await MainActor.run {
                state = .loaded(books)
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }

    /// Borra un libro por id y vuelve a cargar la lista.
    /// La vista puede llamarlo desde swipe-to-delete o un botón.
    func delete(bookId: UUID) async {
        do {
            try await deleteBookUseCase.execute(bookId: bookId)
            await loadLibrary()
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }

    func selectSort(_ option: SortOption) {
        sortOption = option
    }

    func selectGroup(_ option: GroupOption) {
        groupOption = option
    }

    func selectFilter(_ option: FilterOption) {
        filterOption = option
    }

    // MARK: - Helper
    private func makeSections(from dictionary: [String: [Book]]) -> [LibrarySection] {
        dictionary
            .map { key, value in
                LibrarySection(categoryName: key, books: value)
            }
            .sorted {
                $0.categoryName.localizedCaseInsensitiveCompare($1.categoryName) == .orderedAscending
            }
    }
}
