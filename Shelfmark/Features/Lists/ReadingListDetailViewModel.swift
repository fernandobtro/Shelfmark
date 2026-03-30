//
//  ReadingListDetailViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Reading list detail state manager for loading list data and mutating membership.
//

import Foundation
import Observation

/// Coordinates list detail reads plus add/remove-book flows for a single list.
@Observable
final class ReadingListDetailViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded(list: ReadingList, books: [Book])
        case error(String)
    }

    var state: State = .idle
    var isPresentingAddBooksSheet: Bool = false

    var loadedListName: String? {
        guard case .loaded(let list, _) = state else { return nil }
        return list.name
    }

    /// Identifiers for books already present in the list (used by the Add Books sheet).
    var bookIdsInList: Set<UUID> {
        guard case .loaded(_, let books) = state else { return [] }
        return Set(books.map(\.id))
    }

    var currentListId: UUID { listId }

    private let listId: UUID
    private let fetchBooksInListUseCase: FetchBooksInListUseCaseProtocol
    private let fetchReadingListByIdUseCase: FetchReadingListByIdUseCaseProtocol
    private let addBookToReadingListUseCase: AddBookToReadingListUseCaseProtocol
    private let removeBookFromReadingListUseCase: RemoveBookFromReadingListUseCaseProtocol

    init(
        listId: UUID,
        fetchBooksInListUseCase: FetchBooksInListUseCaseProtocol,
        fetchReadingListByIdUseCase: FetchReadingListByIdUseCaseProtocol,
        addBookToReadingListUseCase: AddBookToReadingListUseCaseProtocol,
        removeBookFromReadingListUseCase: RemoveBookFromReadingListUseCaseProtocol
    ) {
        self.listId = listId
        self.fetchBooksInListUseCase = fetchBooksInListUseCase
        self.fetchReadingListByIdUseCase = fetchReadingListByIdUseCase
        self.addBookToReadingListUseCase = addBookToReadingListUseCase
        self.removeBookFromReadingListUseCase = removeBookFromReadingListUseCase
    }

    func load() async {
        await MainActor.run { state = .loading }

        do {
            guard let list = try await fetchReadingListByIdUseCase.execute(listId: listId) else {
                await MainActor.run { state = .error("No se encontró la lista") }
                return
            }

            let books = try await fetchBooksInListUseCase.execute(listId: listId)
            await MainActor.run { state = .loaded(list: list, books: books) }
        } catch {
            await MainActor.run { state = .error(error.localizedDescription) }
        }
    }

    func addBook(bookId: UUID) async {
        do {
            try await addBookToReadingListUseCase.execute(bookId: bookId, listId: listId)
            await load()
        } catch {
            await MainActor.run { state = .error(error.localizedDescription) }
        }
    }

    func removeBook(bookId: UUID) async {
        do {
            try await removeBookFromReadingListUseCase.execute(bookId: bookId, listId: listId)
            await load()
        } catch {
            await MainActor.run { state = .error(error.localizedDescription) }
        }
    }
}
