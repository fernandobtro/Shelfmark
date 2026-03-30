//
//  ListsViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Reading lists state manager: fetch/create/rename/delete plus derived counters and cover previews.
//

import Foundation
import Observation

/// Owns list lifecycle operations and derived UI data for the Lists tab.
@Observable
final class ListsViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded([ReadingList])
        case error(String)
    }

    var state: State = .idle
    var newListName: String = ""
    var isPresentingCreateSheet: Bool = false
    /// Validation error shown by list forms (create/rename).
    var inputErrorMessage: String?

    let pageSize = 20
    var currentOffset = 0
    var hasMore = true
    var isLoadingNextPage = false

    var booksCountByList: [UUID: Int] = [:]
    var previewCoversByList: [UUID: [URL]] = [:]

    private let fetchReadingListsUseCase: FetchReadingListUseCaseProtocol
    private let createReadingListUseCase: CreateReadingListUseCaseProtocol
    private let fetchBooksInListUseCase: FetchBooksInListUseCaseProtocol
    private let renameReadingListUseCase: RenameReadingListUseCaseProtocol
    private let deleteReadingListUseCase: DeleteReadingListUseCaseProtocol
    private let minListNameLength = 2
    private let maxListNameLength = 60

    init(
        fetchReadingListsUseCase: FetchReadingListUseCaseProtocol,
        createReadingListUseCase: CreateReadingListUseCaseProtocol,
        fetchBooksInListUseCase: FetchBooksInListUseCaseProtocol,
        renameReadingListUseCase: RenameReadingListUseCaseProtocol,
        deleteReadingListUseCase: DeleteReadingListUseCaseProtocol
    ) {
        self.fetchReadingListsUseCase = fetchReadingListsUseCase
        self.createReadingListUseCase = createReadingListUseCase
        self.fetchBooksInListUseCase = fetchBooksInListUseCase
        self.renameReadingListUseCase = renameReadingListUseCase
        self.deleteReadingListUseCase = deleteReadingListUseCase
    }

    /// Releases in-memory list state when the user leaves the Lists tab.
    func unload() {
        state = .idle
        currentOffset = 0
        hasMore = true
        booksCountByList = [:]
        previewCoversByList = [:]
    }

    func loadLists() async {
        state = .loading
        currentOffset = 0
        hasMore = true
        do {
            let lists = try await fetchReadingListsUseCase.executePaginated(limit: pageSize, offset: 0)
            await MainActor.run {
                state = .loaded(lists)
                currentOffset = lists.count
                booksCountByList = [:]
                previewCoversByList = [:]
                if lists.count < pageSize {
                    hasMore = false
                }
            }
            await enrichMetadata(for: lists)
        } catch {
            await MainActor.run {
                state = .error(UserFacingError.message(error, fallback: "No se pudieron cargar las listas. Intenta de nuevo."))
            }
        }
    }

    func loadNextPage() async {
        guard !isLoadingNextPage, hasMore else { return }
        guard case .loaded(let existing) = state else { return }
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }
        do {
            let newPage = try await fetchReadingListsUseCase.executePaginated(limit: pageSize, offset: currentOffset)
            await MainActor.run {
                state = .loaded(existing + newPage)
                currentOffset += newPage.count
                if newPage.count < pageSize {
                    hasMore = false
                }
            }
            await enrichMetadata(for: newPage)
        } catch {
            // Keep current list state
        }
    }

    func createList() async {
        let trimmed = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let validationError = validateListName(trimmed, excludingListId: nil) {
            await MainActor.run { inputErrorMessage = validationError }
            return
        }

        do {
            _ = try await createReadingListUseCase.execute(name: trimmed)
            await MainActor.run {
                newListName = ""
                isPresentingCreateSheet = false
                inputErrorMessage = nil
            }
            await loadLists()
        } catch {
            await MainActor.run {
                inputErrorMessage = UserFacingError.message(error, fallback: "No se pudo crear la lista. Intenta de nuevo.")
            }
        }
    }

    func renameList(id: UUID, newName: String) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let validationError = validateListName(trimmed, excludingListId: id) {
            await MainActor.run { inputErrorMessage = validationError }
            return
        }
        do {
            try await renameReadingListUseCase.execute(id: id, newName: trimmed)
            await MainActor.run { inputErrorMessage = nil }
            await loadLists()
        } catch {
            await MainActor.run {
                inputErrorMessage = UserFacingError.message(error, fallback: "No se pudo renombrar la lista. Intenta de nuevo.")
            }
        }
    }

    func deleteList(id: UUID) async {
        do {
            try await deleteReadingListUseCase.execute(id: id)
            await MainActor.run { inputErrorMessage = nil }
            await loadLists()
        } catch {
            await MainActor.run {
                inputErrorMessage = UserFacingError.message(error, fallback: "No se pudo eliminar la lista. Intenta de nuevo.")
            }
        }
    }

    // MARK: - Metadata

    private func enrichMetadata(for lists: [ReadingList]) async {
        var counts = await MainActor.run { booksCountByList }
        var covers = await MainActor.run { previewCoversByList }

        for list in lists {
            let books = (try? await fetchBooksInListUseCase.execute(listId: list.id)) ?? []
            counts[list.id] = books.count
            covers[list.id] = books.compactMap(\.thumbnailURL).prefix(4).map { $0 }
        }

        await MainActor.run {
            booksCountByList = counts
            previewCoversByList = covers
        }
    }

    private func validateListName(_ name: String, excludingListId: UUID?) -> String? {
        if name.isEmpty {
            return "El nombre de la lista es obligatorio."
        }
        if name.count < minListNameLength {
            return "El nombre debe tener al menos \(minListNameLength) caracteres."
        }
        if name.count > maxListNameLength {
            return "El nombre no puede superar \(maxListNameLength) caracteres."
        }

        guard case .loaded(let lists) = state else { return nil }
        let normalizedCandidate = normalizedName(name)
        let duplicateExists = lists.contains { list in
            if let excludingListId, list.id == excludingListId { return false }
            return normalizedName(list.name) == normalizedCandidate
        }
        if duplicateExists {
            return "Ya existe una lista con ese nombre."
        }
        return nil
    }

    private func normalizedName(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .localizedLowercase
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}

