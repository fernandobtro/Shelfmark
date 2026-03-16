//
//  ListsViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation
import Observation

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

    let pageSize = 20
    var currentOffset = 0
    var hasMore = true
    var isLoadingNextPage = false

    private let fetchReadingListsUseCase: FetchReadingListUseCaseProtocol
    private let createReadingListUseCase: CreateReadingListUseCaseProtocol

    init(
        fetchReadingListsUseCase: FetchReadingListUseCaseProtocol,
        createReadingListUseCase: CreateReadingListUseCaseProtocol
    ) {
        self.fetchReadingListsUseCase = fetchReadingListsUseCase
        self.createReadingListUseCase = createReadingListUseCase
    }

    /// Libera las listas en memoria cuando el usuario sale de la pestaña Listas.
    func unload() {
        state = .idle
        currentOffset = 0
        hasMore = true
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
                if lists.count < pageSize {
                    hasMore = false
                }
            }
        } catch {
            await MainActor.run {
                state = .error("No se pudieron cargar las listas: \(error.localizedDescription)")
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
        } catch {
            // Mantenemos la lista actual
        }
    }

    func createList() async {
        let trimmed = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            _ = try await createReadingListUseCase.execute(name: trimmed)
            await MainActor.run {
                newListName = ""
                isPresentingCreateSheet = false
            }
            await loadLists()
        } catch {
            await MainActor.run {
                state = .error("Error al crear la lista: \(error.localizedDescription)")
            }
        }
    }
}
