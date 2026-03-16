//
//  QuotesViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation
import Observation

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

    /// Libros cargados para resolver bookId → título/autor al agrupar y mostrar.
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

    /// Libera citas y libros en memoria cuando el usuario sale de la pestaña Citas.
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
            await MainActor.run {
                books = libraryBooks
                state = .loaded(quotes: quotes)
                currentOffset = quotes.count
                if quotes.count < pageSize {
                    hasMore = false
                }
            }
        } catch {
            await MainActor.run {
                state = .error("No se pudieron cargar las citas: \(error.localizedDescription)")
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
            await MainActor.run {
                state = .loaded(quotes: existingQuotes + newPage)
                currentOffset += newPage.count
                if newPage.count < pageSize {
                    hasMore = false
                }
            }
        } catch {
            // Mantenemos la lista actual; no mostramos error para no interrumpir
        }
    }

    func deleteQuote(quoteId: UUID) async {
        do {
            try await deleteQuoteUseCase.execute(quoteId: quoteId)
            await loadQuotes()
        } catch {
            await MainActor.run {
                state = .error("No se pudo eliminar la cita: \(error.localizedDescription)")
            }
        }
    }

    func setGrouping(_ newGrouping: Grouping) {
        grouping = newGrouping
    }

    /// Secciones para la lista: por libro (bookId) o por autor (nombre del primer autor).
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

    /// Secciones filtradas por búsqueda: por clave (libro/autor) y por texto de la cita.
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
}
