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
    
    /// Para networking (lookup por ISBN)
    private lazy var remoteBookDataSource: RemoteBookDataSource = {
        RemoteBookDataSource(session: URLSession.shared, apiKey: AppSecrets.booksAPIKey)
    }()

    private lazy var remoteBookLookUpRepository: BookLookUpByISBNRepositoryProtocol = {
        RemoteBookLookUpRepository(dataSource: remoteBookDataSource)
    }()

    private lazy var lookUpByISBNUseCase: LookUpByISBNUseCaseProtocol = {
        LookUpByISBNUseCaseImpl(repository: remoteBookLookUpRepository)
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

    // MARK: - Botón Editar desde detalle (instrucciones)
    
    @MainActor
    func makeAddEditBookView(mode: AddEditBookMode) -> AddEditBookView {
        AddEditBookView(viewModel: makeAddEditBookViewModel(mode: mode))
    }
    // Cuando implementes AddEditBookMode.addWithInitialData(Book), para abrir el formulario con un libro del escáner usa:
    // makeAddEditBookView(mode: .addWithInitialData(book))

    @MainActor
    func makeBookDetailViewModel(bookId: UUID) -> BookDetailViewModel {
        BookDetailViewModel(
            bookId: bookId,
            fetchBookDetailUseCase: fetchBookDetailUseCase
        )
    }
    
    @MainActor
    func makeBookScannerViewModel() -> BookScannerViewModel {
        BookScannerViewModel(lookUpByISBNUseCase: lookUpByISBNUseCase)
    }
}
