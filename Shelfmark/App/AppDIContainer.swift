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
    
    /// List Repository based on SwiftData.
    private lazy var readingListRepository: ReadingListRepositoryProtocol = {
        SwiftDataReadingListRepository(modelContext: modelContainer.mainContext)
    }()
    
    /// Quote Repository based on SwiftData
    private lazy var quoteRepository: QuoteRepositoryProtocol = {
        SwiftDataQuoteRepository(modelContext: modelContainer.mainContext)
    }()

    /// User profile (display name, etc.) persisted in UserDefaults.
    private lazy var userProfileRepository: UserProfileRepositoryProtocol = {
        UserDefaultsUserProfileRepository()
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
    
    /// Use Case: fetch Reading Lists
    lazy var fetchReadingListsUseCase: FetchReadingListUseCaseProtocol = {
        FetchReadingListUseCaseImpl(repository: readingListRepository)
    }()
    
    /// Use Case: Create Reading List
    lazy var createReadingListUseCase: CreateReadingListUseCaseProtocol = {
        CreateReadingListUseCaseImpl(repository: readingListRepository)
    }()

    /// Use Case: Rename Reading List
    lazy var renameReadingListUseCase: RenameReadingListUseCaseProtocol = {
        RenameReadingListUseCaseImpl(repository: readingListRepository)
    }()

    /// Use Case: Delete Reading List
    lazy var deleteReadingListUseCase: DeleteReadingListUseCaseProtocol = {
        DeleteReadingListUseCaseImpl(repository: readingListRepository)
    }()
    
    /// Use Case: Fetch Book in List
    lazy var fetchBookInListUseCase: FetchBooksInListUseCaseProtocol = {
        FetchBooksInListUseCaseImpl(repository: readingListRepository)
    }()
    
    /// Use Case: Fetch Book in List by ID
    lazy var fetchReadingListByIdUseCase: FetchReadingListByIdUseCaseProtocol = {
        FetchReadingListByIdUseCaseImpl(repository: readingListRepository)
    }()
    
    /// Use Case Add Book To Reading List
    lazy var addBookToReadingListUseCase: AddBookToReadingListUseCaseProtocol = {
        AddBookToReadingListImpl(repository: readingListRepository)
    }()
    
    /// Use Case: Remove Book From Reading List
    lazy var removeBookFromReadingListUseCase: RemoveBookFromReadingListUseCaseProtocol = {
        RemoveBookFromReadingListUseCaseImpl(repository: readingListRepository)
    }()
    
    /// Use Case: Fetch Quotes
    lazy var fetchQuotesUseCase: FetchQuotesUseCaseProtocol = {
        FetchQuotesUseCaseImpl(repository: quoteRepository)
    }()
    
    /// Use Case: Fetch QuotesByID
    lazy var fetchQuoteByIdUseCase: FetchQuoteByIdUseCaseProtocol = {
        FetchQuoteByIdUseCaseImpl(repository: quoteRepository)
    }()
    
    /// Use Case: Save Quote
    lazy var saveQuoteUseCase: SaveQuoteUseCaseProtocol = {
        SaveQuoteUseCaseImpl(repository: quoteRepository)
    }()
    
    /// Use Case: Delete Quote
    lazy var deleteQuoteUseCase: DeleteQuoteUseCaseProtocol = {
        DeleteQuoteUseCaseImpl(repository: quoteRepository)
    }()

    /// Use Case: métricas de lectura desde libros.
    lazy var calculateReadingStatsUseCase: CalculateReadingStatsUseCaseProtocol = {
        CalculateReadingStatsUseCaseImpl.shared
    }()

    /// Use Case: reconocer texto en imagen (OCR para citas).
    
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
    
    init(useInMemoryStore: Bool = false) {
        do {
            let env = ProcessInfo.processInfo.environment
            let dyldHasXCTest = env["DYLD_INSERT_LIBRARIES"]?
                .localizedCaseInsensitiveContains("xctest") == true
            let isRunningTests =
                env["XCTestConfigurationFilePath"] != nil ||
                env["XCTestBundlePath"] != nil ||
                env["XCInjectBundle"] != nil ||
                env["XCInjectBundleInto"] != nil ||
                dyldHasXCTest ||
                NSClassFromString("XCTestCase") != nil
            if useInMemoryStore || isRunningTests {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(
                    for: BookEntity.self,
                         AuthorEntity.self,
                         PublisherEntity.self,
                         ReadingListEntity.self,
                         ReadingListItemEntity.self,
                         QuoteEntity.self,
                    configurations: config
                )
            } else {
                modelContainer = try ModelContainer(
                    for: BookEntity.self,
                         AuthorEntity.self,
                         PublisherEntity.self,
                         ReadingListEntity.self,
                         ReadingListItemEntity.self,
                         QuoteEntity.self
                )
            }
        } catch {
            fatalError("No se pudo inicializar la base de datos: \(error)")
        }
    }
}

// MARK: - ViewModel Factories

@MainActor
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
    func makeAddEditBookView(mode: AddEditBookMode) -> AddEditBookView {
        AddEditBookView(viewModel: makeAddEditBookViewModel(mode: mode))
    }

    @MainActor
    func makeBookDetailViewModel(bookId: UUID) -> BookDetailViewModel {
        BookDetailViewModel(
            bookId: bookId,
            fetchBookDetailUseCase: fetchBookDetailUseCase,
            deleteBookUseCase: deleteBookUseCase,
            fetchQuotesUseCase: fetchQuotesUseCase,
            saveBookUseCase: saveBookUseCase
        )
    }
    
    @MainActor
    func makeBookScannerViewModel() -> BookScannerViewModel {
        BookScannerViewModel(lookUpByISBNUseCase: lookUpByISBNUseCase)
    }
    
    @MainActor
    func makeListsViewModel() -> ListsViewModel {
        ListsViewModel(
            fetchReadingListsUseCase: fetchReadingListsUseCase,
            createReadingListUseCase: createReadingListUseCase,
            fetchBooksInListUseCase: fetchBookInListUseCase,
            renameReadingListUseCase: renameReadingListUseCase,
            deleteReadingListUseCase: deleteReadingListUseCase
        )
    }
    
    @MainActor
    func makeReadingListDetailViewModel(listId: UUID) -> ReadingListDetailViewModel {
        ReadingListDetailViewModel(
            listId: listId,
            fetchBooksInListUseCase: fetchBookInListUseCase,
            fetchReadingListByIdUseCase: fetchReadingListByIdUseCase,
            addBookToReadingListUseCase: addBookToReadingListUseCase,
            removeBookFromReadingListUseCase: removeBookFromReadingListUseCase
        )
    }
    
    @MainActor
    func makeQuotesViewModel() -> QuotesViewModel {
        QuotesViewModel(
            fetchQuotesUseCase: fetchQuotesUseCase,
            fetchLibraryUseCase: fetchLibraryUseCase,
            deleteQuoteUseCase: deleteQuoteUseCase
        )
    }

    @MainActor
    func makeAddEditQuoteViewModel(mode: AddEditQuoteMode) -> AddEditQuoteViewModel {
        AddEditQuoteViewModel(
            mode: mode,
            saveQuoteUseCase: saveQuoteUseCase,
            fetchQuoteByIdUseCase: fetchQuoteByIdUseCase,
            fetchLibraryUseCase: fetchLibraryUseCase,
            deleteQuoteUseCase: deleteQuoteUseCase
        )
    }

    @MainActor
    func makeQuoteDetailViewModel(quoteId: UUID) -> QuoteDetailViewModel {
        QuoteDetailViewModel(
            quoteId: quoteId,
            fetchQuoteByIdUseCase: fetchQuoteByIdUseCase,
            fetchBookDetailUseCase: fetchBookDetailUseCase,
            deleteQuoteUseCase: deleteQuoteUseCase
        )
    }

    @MainActor
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            userProfileRepository: userProfileRepository,
            fetchLibraryUseCase: fetchLibraryUseCase,
            fetchQuotesUseCase: fetchQuotesUseCase,
            fetchReadingListsUseCase: fetchReadingListsUseCase
        )
    }

    @MainActor
    func makeLibraryStatsViewModel() -> LibraryStatsViewModel {
        LibraryStatsViewModel(
            fetchLibraryUseCase: fetchLibraryUseCase,
            calculateReadingStatsUseCase: calculateReadingStatsUseCase
        )
    }
}
