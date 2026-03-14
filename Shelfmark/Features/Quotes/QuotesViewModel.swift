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

    /// Libros cargados para resolver bookId → título/autor al agrupar y mostrar.
    private(set) var books: [Book] = []

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

    func loadQuotes() async {
        state = .loading
        do {
            async let quotesTask = fetchQuotesUseCase.execute()
            async let booksTask = fetchLibraryUseCase.execute()
            let (quotes, libraryBooks) = try await (quotesTask, booksTask)
            await MainActor.run {
                books = libraryBooks
                state = .loaded(quotes: quotes)
            }
        } catch {
            await MainActor.run {
                state = .error("No se pudieron cargar las citas: \(error.localizedDescription)")
            }
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
}
