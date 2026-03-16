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
                        // Sección fija
                        Section("Fijas") {
                            FixedListRowView(
                                systemImage: "bookmark",
                                title: "Por leer",
                                subtitle: "Libros marcados como pendientes"
                            )
                            FixedListRowView(
                                systemImage: "book",
                                title: "Leídos",
                                subtitle: "Todos los libros terminados"
                            )
                            FixedListRowView(
                                systemImage: "heart.fill",
                                title: "Favoritos",
                                subtitle: "Libros marcados como favoritos"
                            )
                        }

                        // Sección de listas del usuario
                        Section("Mis listas") {
                            ForEach(lists, id: \.id) { list in
                                NavigationLink(value: list.id) {
                                    ReadingListCellView(
                                        list: list,
                                        booksCount: viewModel.booksCountByList[list.id] ?? 0,
                                        previewCoverURLs: viewModel.previewCoversByList[list.id] ?? []
                                    )
                                }
                            }

                            if viewModel.hasMore {
                                Section {
                                    if viewModel.isLoadingNextPage {
                                        ProgressView()
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                    } else {
                                        Color.clear
                                            .frame(height: 1)
                                            .task { await viewModel.loadNextPage() }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
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
        .background(Color.theme.mainBackground)
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
    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList] {
        Array(lists.dropFirst(offset).prefix(limit))
    }
}

private struct PreviewFetchListsUseCaseThrowing: FetchReadingListUseCaseProtocol {
    func execute() async throws -> [ReadingList] {
        throw NSError(domain: "Preview", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudieron cargar las listas."])
    }
    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList] {
        throw NSError(domain: "Preview", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudieron cargar las listas."])
    }
}

private struct PreviewCreateListUseCase: CreateReadingListUseCaseProtocol {
    func execute(name: String) async throws -> ReadingList {
        ReadingList(id: UUID(), name: name, createdAt: Date(), iconName: "", notes: "")
    }
}
