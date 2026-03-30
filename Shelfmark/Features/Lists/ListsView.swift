//
//  ListsView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Reading lists screen with CRUD actions, pagination, and navigation into list/book detail routes.
//

import SwiftUI
import Observation

/// Displays list collections, row actions, and validation/error feedback for list management.
struct ListsView: View {
    @Bindable var viewModel: ListsViewModel
    @State private var selectedList: ReadingList?
    @State private var renameText: String = ""
    @State private var showRenameAlert = false
    @State private var showDeleteAlert = false
    @State private var retryTrigger = 0

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
                        Section("Mis listas") {
                            ForEach(lists, id: \.id) { list in
                                NavigationLink(value: ListsRoute.list(list.id)) {
                                    ReadingListCellView(
                                        list: list,
                                        booksCount: viewModel.booksCountByList[list.id] ?? 0,
                                        previewCoverURLs: viewModel.previewCoversByList[list.id] ?? []
                                    )
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Renombrar") {
                                        selectedList = list
                                        renameText = list.name
                                        showRenameAlert = true
                                    }
                                    .tint(.blue)

                                    Button(role: .destructive) {
                                        selectedList = list
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        selectedList = list
                                        renameText = list.name
                                        showRenameAlert = true
                                    } label: {
                                        Label("Renombrar", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        selectedList = list
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                            }

                            if viewModel.hasMore {
                                Section {
                                    if viewModel.isLoadingNextPage {
                                        ProgressView()
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                    } else {
                                        Color.clear
                                            .frame(height: 1)
                                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .task { await viewModel.loadNextPage() }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

            case .error(let message):
                VStack(spacing: 12) {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                    Button("Reintentar") {
                        retryTrigger += 1
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.theme.mainBackground)
        .navigationTitle("Listas")
        .task(id: retryTrigger) {
            await viewModel.loadLists()
        }
        .alert("Renombrar lista", isPresented: $showRenameAlert) {
            TextField("Nombre", text: $renameText)
                .accessibilityIdentifier("lists.rename.nameField")
            Button("Cancelar", role: .cancel) {
                selectedList = nil
            }
            Button("Guardar") {
                guard let id = selectedList?.id else { return }
                Task {
                    await viewModel.renameList(id: id, newName: renameText)
                    selectedList = nil
                }
            }
            .accessibilityIdentifier("lists.rename.confirmButton")
        } message: {
            Text("Elige un nombre para tu lista.")
        }
        .alert("Eliminar lista", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {
                selectedList = nil
            }
            Button("Eliminar", role: .destructive) {
                guard let id = selectedList?.id else { return }
                Task {
                    await viewModel.deleteList(id: id)
                    selectedList = nil
                }
            }
            .accessibilityIdentifier("lists.delete.confirmButton")
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .alert(
            "No se pudo completar",
            isPresented: Binding(
                get: { (viewModel.inputErrorMessage ?? "").isEmpty == false },
                set: { isPresented in
                    if !isPresented {
                        viewModel.inputErrorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.inputErrorMessage = nil
            }
        } message: {
            Text(viewModel.inputErrorMessage ?? "")
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
        createReadingListUseCase: PreviewCreateListUseCase(),
        fetchBooksInListUseCase: PreviewFetchBooksInListForLists(),
        renameReadingListUseCase: PreviewRenameListUseCase(),
        deleteReadingListUseCase: PreviewDeleteListUseCase()
    )
    NavigationStack {
        ListsView(viewModel: viewModel)
            .task { await viewModel.loadLists() }
    }
}

#Preview("Sin listas") {
    let viewModel = ListsViewModel(
        fetchReadingListsUseCase: PreviewFetchListsUseCase(lists: []),
        createReadingListUseCase: PreviewCreateListUseCase(),
        fetchBooksInListUseCase: PreviewFetchBooksInListForLists(),
        renameReadingListUseCase: PreviewRenameListUseCase(),
        deleteReadingListUseCase: PreviewDeleteListUseCase()
    )
    NavigationStack {
        ListsView(viewModel: viewModel)
            .task { await viewModel.loadLists() }
    }
}

#Preview("Error") {
    let viewModel = ListsViewModel(
        fetchReadingListsUseCase: PreviewFetchListsUseCaseThrowing(),
        createReadingListUseCase: PreviewCreateListUseCase(),
        fetchBooksInListUseCase: PreviewFetchBooksInListForLists(),
        renameReadingListUseCase: PreviewRenameListUseCase(),
        deleteReadingListUseCase: PreviewDeleteListUseCase()
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

private struct PreviewFetchBooksInListForLists: FetchBooksInListUseCaseProtocol {
    func execute(listId: UUID) async throws -> [Book] { [] }
}

private struct PreviewRenameListUseCase: RenameReadingListUseCaseProtocol {
    func execute(id: UUID, newName: String) async throws {}
}

private struct PreviewDeleteListUseCase: DeleteReadingListUseCaseProtocol {
    func execute(id: UUID) async throws {}
}
