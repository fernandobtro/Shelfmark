//
//  ProfileViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import Foundation
import Observation

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

    /// Libera el estado cargado cuando el usuario sale de la pestaña Perfil.
    func unload() {
        state = .idle
    }

    func load() async {
        await MainActor.run {
            state = .loading
            displayName = userProfileRepository.getDisplayName()
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
}
