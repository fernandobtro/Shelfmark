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

    private let fetchReadingListsUseCase: FetchReadingListUseCaseProtocol
    private let createReadingListUseCase: CreateReadingListUseCaseProtocol

    init(
        fetchReadingListsUseCase: FetchReadingListUseCaseProtocol,
        createReadingListUseCase: CreateReadingListUseCaseProtocol
    ) {
        self.fetchReadingListsUseCase = fetchReadingListsUseCase
        self.createReadingListUseCase = createReadingListUseCase
    }

    func loadLists() async {
        state = .loading

        do {
            let lists = try await fetchReadingListsUseCase.execute()
            await MainActor.run {
                state = .loaded(lists)
            }
        } catch {
            await MainActor.run {
                state = .error("No se pudieron cargar las listas: \(error.localizedDescription)")
            }
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
