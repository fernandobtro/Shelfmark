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

    // MARK: - Instrucciones (completa en orden)
    // 1. ~~Añade @Published var sortOption: SortOption = .title y @Published var groupOption: GroupOption = .none.~~ Hecho.
    // 2. Añade @Published var filterOption: FilterOption = .all (enum en LibraryModels). No hace falta inyectar nada nuevo; el filtro se aplica sobre los libros ya cargados.
    
    @Published var filterOption: FilterOption = .all
    
    // 3. sectionedBooks: [LibrarySection]. Computa a partir de state, filterOption, sortOption y groupOption.
    //    Lógica:
    //    (a) del state extrae [Book] (solo si .loaded),
    //    (b) filtra por filterOption (de momento todos),
    //    (c) ordena por sortOption (título o primer autor),
    //    (d) agrupa según groupOption o devuelve una única sección "Todos".
    var sectionedBooks: [LibrarySection] {
        guard case .loaded(let books) = state else { return [] }

        // (b) Filtro (por ahora: todos los libros; más adelante usaremos filterOption)
        let filteredBooks = books.filter { _ in true }

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
    // 4. Añade métodos para la vista: selectSort(_ option: SortOption), selectGroup(_ option: GroupOption), selectFilter(_ option: FilterOption). Solo asignan las @Published; no hace falta crear use cases.

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
