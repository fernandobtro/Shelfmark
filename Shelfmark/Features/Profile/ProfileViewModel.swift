//
//  ProfileViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//
//  Purpose: Profile state manager for display-name persistence and aggregated library/quotes/lists metrics.
//

import Foundation
import Observation

/// Loads profile data and computed counters for the Profile tab.
@Observable
final class ProfileViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(booksCount: Int, quotesCount: Int, listsCount: Int)
        case error(String)
    }

    var state: State = .idle
    var displayName: String = ""
    var libraryGridLayoutOption: LibraryGridLayoutOption = .standard

    private let userProfileRepository: UserProfileRepositoryProtocol
    private let fetchLibraryUseCase: FetchLibraryUseCaseProtocol
    private let fetchQuotesUseCase: FetchQuotesUseCaseProtocol
    private let fetchReadingListsUseCase: FetchReadingListUseCaseProtocol

    init(
        userProfileRepository: UserProfileRepositoryProtocol,
        fetchLibraryUseCase: FetchLibraryUseCaseProtocol,
        fetchQuotesUseCase: FetchQuotesUseCaseProtocol,
        fetchReadingListsUseCase: FetchReadingListUseCaseProtocol
    ) {
        self.userProfileRepository = userProfileRepository
        self.fetchLibraryUseCase = fetchLibraryUseCase
        self.fetchQuotesUseCase = fetchQuotesUseCase
        self.fetchReadingListsUseCase = fetchReadingListsUseCase
    }

    /// Releases loaded state when the user leaves the Profile tab.
    func unload() {
        state = .idle
    }

    func load() async {
        await MainActor.run {
            state = .loading
            displayName = userProfileRepository.getDisplayName()
            libraryGridLayoutOption = userProfileRepository.getLibraryGridLayoutOption()
        }

        do {
            async let booksTask = fetchLibraryUseCase.execute()
            async let quotesTask = fetchQuotesUseCase.execute()
            async let listsTask = fetchReadingListsUseCase.execute()
            let (books, quotes, lists) = try await (booksTask, quotesTask, listsTask)
            await MainActor.run {
                state = .loaded(
                    booksCount: books.count,
                    quotesCount: quotes.count,
                    listsCount: lists.count
                )
            }
        } catch {
            await MainActor.run {
                state = .error("No se pudieron cargar las estadísticas.")
            }
        }
    }

    func saveDisplayName(_ name: String) {
        displayName = name
        userProfileRepository.setDisplayName(name)
    }

    func setLibraryGridLayoutOption(_ option: LibraryGridLayoutOption) {
        libraryGridLayoutOption = option
        userProfileRepository.setLibraryGridLayoutOption(option)
    }
}
