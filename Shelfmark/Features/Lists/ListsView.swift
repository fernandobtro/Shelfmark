//
//  ListsView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import SwiftUI
import Observation

struct ListsView: View {
    @Bindable var viewModel: ListsViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando listas…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let lists):
                if lists.isEmpty {
                    ContentUnavailableView(
                        "Sin listas",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Pulsa + para crear tu primera lista.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(lists, id: \.id) { list in
                            NavigationLink(value: list.id) {
                                Text(list.name)
                            }
                        }
                    }
                }

            case .error(let message):
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Listas")
        .task {
            await viewModel.loadLists()
        }
    }
}

// MARK: - Previews

#Preview("Con listas") {
    let viewModel = ListsViewModel(
        fetchReadingListsUseCase: PreviewFetchListsUseCase(lists: [
            ReadingList(id: UUID(), name: "Libros para leer en 2026", createdAt: Date(), iconName: "", notes: ""),
            ReadingList(id: UUID(), name: "Marzo 2026", createdAt: Date(), iconName: "", notes: ""),
        ]),
        createReadingListUseCase: PreviewCreateListUseCase()
    )
    NavigationStack {
        ListsView(viewModel: viewModel)
            .task { await viewModel.loadLists() }
    }
}

#Preview("Sin listas") {
    let viewModel = ListsViewModel(
        fetchReadingListsUseCase: PreviewFetchListsUseCase(lists: []),
        createReadingListUseCase: PreviewCreateListUseCase()
    )
    NavigationStack {
        ListsView(viewModel: viewModel)
            .task { await viewModel.loadLists() }
    }
}

#Preview("Error") {
    let viewModel = ListsViewModel(
        fetchReadingListsUseCase: PreviewFetchListsUseCaseThrowing(),
        createReadingListUseCase: PreviewCreateListUseCase()
    )
    NavigationStack {
        ListsView(viewModel: viewModel)
            .task { await viewModel.loadLists() }
    }
}

private struct PreviewFetchListsUseCase: FetchReadingListUseCaseProtocol {
    let lists: [ReadingList]
    func execute() async throws -> [ReadingList] { lists }
}

private struct PreviewFetchListsUseCaseThrowing: FetchReadingListUseCaseProtocol {
    func execute() async throws -> [ReadingList] {
        throw NSError(domain: "Preview", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudieron cargar las listas."])
    }
}

private struct PreviewCreateListUseCase: CreateReadingListUseCaseProtocol {
    func execute(name: String) async throws -> ReadingList {
        ReadingList(id: UUID(), name: name, createdAt: Date(), iconName: "", notes: "")
    }
}
