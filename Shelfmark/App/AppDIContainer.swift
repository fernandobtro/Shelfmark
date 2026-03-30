//
//  AppDIContainer.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Composition root for Shelfmark dependencies and view model factories.
//

import Foundation
import SwiftData

/// Composition root for Shelfmark dependencies and view model factories.
final class AppDIContainer {
    /// Main SwiftData container used across the app.
    /// Exposed to integrate with SwiftUI via `.modelContainer`.
    let modelContainer: ModelContainer

    /// SwiftData-backed repository for books.
    private lazy var bookRepository: BookRepositoryProtocol = {
        SwiftDataBookRepository(modelContext: modelContainer.mainContext)
    }()
    
    private lazy var readingListRepository: ReadingListRepositoryProtocol = {
        SwiftDataReadingListRepository(modelContext: modelContainer.mainContext)
    }()
    
    private lazy var quoteRepository: QuoteRepositoryProtocol = {
        SwiftDataQuoteRepository(modelContext: modelContainer.mainContext)
    }()

    private lazy var userProfileRepository: UserProfileRepositoryProtocol = {
        UserDefaultsUserProfileRepository()
    }()

    lazy var fetchLibraryUseCase: FetchLibraryUseCaseProtocol = {
        FetchLibraryUseCaseImpl(repository: bookRepository)
    }()

    lazy var fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol = {
        FetchBookDetailUseCaseImpl(repository: bookRepository)
    }()

    lazy var saveBookUseCase: SaveBookUseCaseProtocol = {
        SaveBookUseCaseImpl(repository: bookRepository)
    }()

    lazy var deleteBookUseCase: DeleteBookUseCaseProtocol = {
        DeleteBookUseCaseImpl(repository: bookRepository)
    }()
    
    lazy var fetchReadingListsUseCase: FetchReadingListUseCaseProtocol = {
        FetchReadingListUseCaseImpl(repository: readingListRepository)
    }()
    
    lazy var createReadingListUseCase: CreateReadingListUseCaseProtocol = {
        CreateReadingListUseCaseImpl(repository: readingListRepository)
    }()

    lazy var renameReadingListUseCase: RenameReadingListUseCaseProtocol = {
        RenameReadingListUseCaseImpl(repository: readingListRepository)
    }()

    lazy var deleteReadingListUseCase: DeleteReadingListUseCaseProtocol = {
        DeleteReadingListUseCaseImpl(repository: readingListRepository)
    }()
    
    lazy var fetchBookInListUseCase: FetchBooksInListUseCaseProtocol = {
        FetchBooksInListUseCaseImpl(repository: readingListRepository)
    }()
    
    lazy var fetchReadingListByIdUseCase: FetchReadingListByIdUseCaseProtocol = {
        FetchReadingListByIdUseCaseImpl(repository: readingListRepository)
    }()
    
    lazy var addBookToReadingListUseCase: AddBookToReadingListUseCaseProtocol = {
        AddBookToReadingListImpl(repository: readingListRepository)
    }()
    
    lazy var removeBookFromReadingListUseCase: RemoveBookFromReadingListUseCaseProtocol = {
        RemoveBookFromReadingListUseCaseImpl(repository: readingListRepository)
    }()
    
    lazy var fetchQuotesUseCase: FetchQuotesUseCaseProtocol = {
        FetchQuotesUseCaseImpl(repository: quoteRepository)
    }()
    
    lazy var fetchQuoteByIdUseCase: FetchQuoteByIdUseCaseProtocol = {
        FetchQuoteByIdUseCaseImpl(repository: quoteRepository)
    }()
    
    lazy var saveQuoteUseCase: SaveQuoteUseCaseProtocol = {
        SaveQuoteUseCaseImpl(repository: quoteRepository)
    }()
    
    lazy var deleteQuoteUseCase: DeleteQuoteUseCaseProtocol = {
        DeleteQuoteUseCaseImpl(repository: quoteRepository)
    }()

    lazy var calculateReadingStatsUseCase: CalculateReadingStatsUseCaseProtocol = {
        CalculateReadingStatsUseCaseImpl.shared
    }()

    // MARK: - Networking
    
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
            deleteBookUseCase: deleteBookUseCase,
            userProfileRepository: userProfileRepository
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
    func makeQuoteTextScannerViewModel() -> QuoteTextScannerViewModel {
        QuoteTextScannerViewModel()
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
