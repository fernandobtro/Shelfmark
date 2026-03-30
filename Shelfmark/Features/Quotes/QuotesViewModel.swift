//
//  QuotesViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Quotes tab state and actions: paginated loading, grouping projections, deduplication, and delete handling.
//

import Foundation
import Observation

/// Coordinates quote/library reads and builds grouped, searchable quote projections.
@Observable
final class QuotesViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(quotes: [Quote])
        case error(String)
    }

    enum Grouping: Equatable {
        case byBook
        case byAuthor
    }

    var state: State = .idle
    var grouping: Grouping = .byBook
    var searchText: String = ""

    /// Loaded books used to resolve bookId into title/author metadata for grouping and rendering.
    private(set) var books: [Book] = []

    let pageSize = 20
    var currentOffset = 0
    var hasMore = true
    var isLoadingNextPage = false

    private let fetchQuotesUseCase: FetchQuotesUseCaseProtocol
    private let fetchLibraryUseCase: FetchLibraryUseCaseProtocol
    private let deleteQuoteUseCase: DeleteQuoteUseCaseProtocol

    init(
        fetchQuotesUseCase: FetchQuotesUseCaseProtocol,
        fetchLibraryUseCase: FetchLibraryUseCaseProtocol,
        deleteQuoteUseCase: DeleteQuoteUseCaseProtocol
    ) {
        self.fetchQuotesUseCase = fetchQuotesUseCase
        self.fetchLibraryUseCase = fetchLibraryUseCase
        self.deleteQuoteUseCase = deleteQuoteUseCase
    }

    /// Releases in-memory quotes and books when the user leaves the Quotes tab.
    func unload() {
        state = .idle
        books = []
        currentOffset = 0
        hasMore = true
    }

    func loadQuotes() async {
        state = .loading
        currentOffset = 0
        hasMore = true
        do {
            async let quotesTask = fetchQuotesUseCase.executePaginated(limit: pageSize, offset: 0)
            async let booksTask = fetchLibraryUseCase.execute()
            let (quotes, libraryBooks) = try await (quotesTask, booksTask)
            let dedupedQuotes = deduplicateQuotes(quotes)
            await MainActor.run {
                books = libraryBooks
                state = .loaded(quotes: dedupedQuotes)
                currentOffset = quotes.count
                if quotes.count < pageSize {
                    hasMore = false
                }
            }
        } catch {
            await MainActor.run {
                state = .error(UserFacingError.message(error, fallback: "No se pudieron cargar las citas. Intenta de nuevo."))
            }
        }
    }

    func loadNextPage() async {
        guard !isLoadingNextPage, hasMore else { return }
        guard case .loaded(let existingQuotes) = state else { return }
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }
        do {
            let newPage = try await fetchQuotesUseCase.executePaginated(limit: pageSize, offset: currentOffset)
            let mergedQuotes = deduplicateQuotes(existingQuotes + newPage)
            await MainActor.run {
                state = .loaded(quotes: mergedQuotes)
                currentOffset += newPage.count
                if newPage.count < pageSize {
                    hasMore = false
                }
            }
        } catch {
            // Keep current list state; skip inline error to avoid navigation interruption.
        }
    }

    func deleteQuote(quoteId: UUID) async {
        do {
            try await deleteQuoteUseCase.execute(quoteId: quoteId)
            await loadQuotes()
        } catch {
            await MainActor.run {
                state = .error(UserFacingError.message(error, fallback: "No se pudo eliminar la cita. Intenta de nuevo."))
            }
        }
    }

    func setGrouping(_ newGrouping: Grouping) {
        grouping = newGrouping
    }

    /// List sections grouped by book (`bookId`) or by first-author name.
    var sectionedQuotes: [(key: String, quotes: [Quote])] {
        guard case .loaded(let quotes) = state else { return [] }
        let bookById = Dictionary(uniqueKeysWithValues: books.map { ($0.id, $0) })

        switch grouping {
        case .byBook:
            let grouped = Dictionary(grouping: quotes, by: { $0.bookId })
            return grouped.keys.sorted { bookById[$0]?.title ?? "" < bookById[$1]?.title ?? "" }
                .map { id in
                    let title = bookById[id]?.title ?? "Sin título"
                    return (key: title, quotes: grouped[id] ?? [])
                }
        case .byAuthor:
            let grouped = Dictionary(grouping: quotes) { quote in
                bookById[quote.bookId]?.authors.first?.name ?? "Autor desconocido"
            }
            return grouped.keys.sorted().map { (key: $0, quotes: grouped[$0] ?? []) }
        }
    }

    /// Search-filtered sections by grouping key (book/author) and quote text.
    var filteredSectionedQuotes: [(key: String, quotes: [Quote])] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return sectionedQuotes }
        let normalized = query.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current)
        return sectionedQuotes.compactMap { section -> (key: String, quotes: [Quote])? in
            let keyMatch = section.key.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(normalized)
            let filteredQuotes = section.quotes.filter { quote in
                quote.text.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(normalized)
            }
            if keyMatch {
                return (key: section.key, quotes: section.quotes)
            }
            if filteredQuotes.isEmpty { return nil }
            return (key: section.key, quotes: filteredQuotes)
        }
    }

    /// Books with quote counts for the By Book view, honoring active search.
    var booksWithQuoteCount: [(Book, Int)] {
        guard case .loaded(let quotes) = state else { return [] }
        let bookById = Dictionary(uniqueKeysWithValues: books.map { ($0.id, $0) })
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = query.isEmpty ? nil : query.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current)
        let quotesToUse: [Quote]
        if let n = normalized {
            quotesToUse = quotes.filter { q in
                q.text.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(n)
                || (bookById[q.bookId].map { b in
                    (b.title + " " + b.authors.map(\.name).joined(separator: " "))
                        .localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(n)
                } ?? false)
            }
        } else {
            quotesToUse = quotes
        }
        let grouped = Dictionary(grouping: quotesToUse, by: { $0.bookId })
        return grouped.keys.compactMap { bookId -> (Book, Int)? in
            guard let book = bookById[bookId], let list = grouped[bookId] else { return nil }
            return (book, list.count)
        }.sorted { $0.0.title.localizedCaseInsensitiveCompare($1.0.title) == .orderedAscending }
    }

    /// Authors with quote counts for the By Author view, honoring active search.
    var authorsWithQuoteCount: [(name: String, count: Int)] {
        guard grouping == .byAuthor else { return [] }
        return filteredSectionedQuotes.map { (name: $0.key, count: $0.quotes.count) }
    }

    /// Quotes for a specific book, used by By Book navigation.
    func quotes(forBookId bookId: UUID) -> [Quote] {
        guard case .loaded(let quotes) = state else { return [] }
        return quotes.filter { $0.bookId == bookId }
    }

    /// Quotes for a specific author, used by By Author navigation.
    func quotes(forAuthor authorName: String) -> [Quote] {
        let bookById = Dictionary(uniqueKeysWithValues: books.map { ($0.id, $0) })
        guard case .loaded(let quotes) = state else { return [] }
        return quotes.filter { bookById[$0.bookId]?.authors.first?.name == authorName }
    }

    /// Removes duplicate quote IDs to keep `ForEach` identity stable and keeps descending date order.
    private func deduplicateQuotes(_ quotes: [Quote]) -> [Quote] {
        var seen: Set<UUID> = []
        let sorted = quotes.sorted { $0.createdAt > $1.createdAt }
        return sorted.filter { quote in
            if seen.contains(quote.id) { return false }
            seen.insert(quote.id)
            return true
        }
    }
}
