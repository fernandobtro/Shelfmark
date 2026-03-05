//
//  AppDIContainer.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation
import SwiftData

final class AppDIContainer {
    /// Contenedor principal de SwiftData para toda la app.
    /// Se expone para poder integrarlo con SwiftUI (.modelContainer).
    let modelContainer: ModelContainer

    /// Repositorio de libros basado en SwiftData.
    private lazy var bookRepository: BookRepositoryProtocol = {
        SwiftDataBookRepository(modelContext: modelContainer.mainContext)
    }()

    /// Caso de uso: obtener toda la biblioteca.
    lazy var fetchLibraryUseCase: FetchLibraryUseCaseProtocol = {
        FetchLibraryUseCaseImpl(repository: bookRepository)
    }()

    /// Caso de uso: obtener el detalle de un libro.
    lazy var fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol = {
        FetchBookDetailUseCaseImpl(repository: bookRepository)
    }()

    /// Caso de uso: guardar (crear/editar) un libro.
    lazy var saveBookUseCase: SaveBookUseCaseProtocol = {
        SaveBookUseCaseImpl(repository: bookRepository)
    }()

    /// Caso de uso: eliminar un libro.
    lazy var deleteBookUseCase: DeleteBookUseCaseProtocol = {
        DeleteBookUseCaseImpl(repository: bookRepository)
    }()

    init() {
        do {
            modelContainer = try ModelContainer(
                for: BookEntity.self,
                     AuthorEntity.self,
                     PublisherEntity.self
            )
        } catch {
            fatalError("No se pudo inicializar la base de datos: \(error)")
        }
    }
}

// MARK: - ViewModel Factories

extension AppDIContainer {
    @MainActor
    func makeLibraryViewModel() -> LibraryViewModel {
        LibraryViewModel(
            fetchLibraryUseCase: fetchLibraryUseCase,
            deleteBookUseCase: deleteBookUseCase
        )
    }

    @MainActor
    func makeAddEditBookViewModel(mode: AddEditBookMode) -> AddEditBookViewModel {
        AddEditBookViewModel(
            mode: mode,
            saveBookUseCase: saveBookUseCase
        )
    }

    @MainActor
    func makeAddBookView() -> AddEditBookView {
        AddEditBookView(viewModel: makeAddEditBookViewModel(mode: .add))
    }

    @MainActor
    func makeBookDetailViewModel(bookId: UUID) -> BookDetailViewModel {
        BookDetailViewModel(
            bookId: bookId,
            fetchBookDetailUseCase: fetchBookDetailUseCase
        )
    }
}
