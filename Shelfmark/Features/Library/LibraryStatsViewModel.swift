//
//  LibraryStatsViewModel.swift
//  Shelfmark
//

import Foundation
import Observation

enum LibraryStatsState: Equatable {
    case idle
    case loading
    case loaded(ReadingStats)
    case error(String)
}

@Observable
final class LibraryStatsViewModel {
    var state: LibraryStatsState = .idle

    private let fetchLibraryUseCase: FetchLibraryUseCaseProtocol
    private let calculateReadingStatsUseCase: CalculateReadingStatsUseCaseProtocol

    init(
        fetchLibraryUseCase: FetchLibraryUseCaseProtocol,
        calculateReadingStatsUseCase: CalculateReadingStatsUseCaseProtocol
    ) {
        self.fetchLibraryUseCase = fetchLibraryUseCase
        self.calculateReadingStatsUseCase = calculateReadingStatsUseCase
    }

    func load() async {
        state = .loading
        do {
            let books = try await fetchLibraryUseCase.execute()
            let stats = calculateReadingStatsUseCase.execute(books: books)
            await MainActor.run {
                state = .loaded(stats)
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }
}
