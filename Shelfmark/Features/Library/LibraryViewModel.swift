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
}
