//
//  QuoteDetailViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation
import Observation

@Observable
final class QuoteDetailViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(quote: Quote, book: Book?)
        case error(String)
        case deleted
    }

    var state: State = .idle

    var quoteId: UUID { id }
    private let id: UUID
    private let fetchQuoteByIdUseCase: FetchQuoteByIdUseCaseProtocol
    private let fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol
    private let deleteQuoteUseCase: DeleteQuoteUseCaseProtocol

    init(
        quoteId: UUID,
        fetchQuoteByIdUseCase: FetchQuoteByIdUseCaseProtocol,
        fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol,
        deleteQuoteUseCase: DeleteQuoteUseCaseProtocol
    ) {
        self.id = quoteId
        self.fetchQuoteByIdUseCase = fetchQuoteByIdUseCase
        self.fetchBookDetailUseCase = fetchBookDetailUseCase
        self.deleteQuoteUseCase = deleteQuoteUseCase
    }

    func load() async {
        await MainActor.run { state = .loading }

        do {
            guard let quote = try await fetchQuoteByIdUseCase.execute(quoteId: id) else {
                await MainActor.run { state = .error("No se encontró la cita") }
                return
            }
            let book = try? await fetchBookDetailUseCase.execute(bookId: quote.bookId)
            await MainActor.run { state = .loaded(quote: quote, book: book) }
        } catch {
            await MainActor.run { state = .error(error.localizedDescription) }
        }
    }

    func deleteQuote() async {
        do {
            try await deleteQuoteUseCase.execute(quoteId: id)
            await MainActor.run { state = .deleted }
        } catch {
            await MainActor.run { state = .error(error.localizedDescription) }
        }
    }
}
