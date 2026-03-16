//
//  CreateListSheetView.swift
//  Shelfmark
//
//  Sheet para crear una nueva lista; se presenta desde RootView al pulsar + en la pestaña Listas.
//

import SwiftUI
import Observation

struct CreateListSheetView: View {
    @Bindable var viewModel: ListsViewModel
    var onDismiss: () -> Void
    @State private var createTrigger = 0

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre de la lista", text: $viewModel.newListName)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTapOutside()
            .navigationTitle("Nueva lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        viewModel.newListName = ""
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        createTrigger += 1
                    }
                    .disabled(viewModel.newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task(id: createTrigger) {
                if createTrigger > 0 {
                    await viewModel.createList()
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = ListsViewModel(
        fetchReadingListsUseCase: PreviewCreateListFetchUseCase(),
        createReadingListUseCase: PreviewCreateListCreateUseCase()
    )
    return CreateListSheetView(viewModel: vm, onDismiss: {})
}

private struct PreviewCreateListFetchUseCase: FetchReadingListUseCaseProtocol {
    func execute() async throws -> [ReadingList] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList] { [] }
}

private struct PreviewCreateListCreateUseCase: CreateReadingListUseCaseProtocol {
    func execute(name: String) async throws -> ReadingList {
        ReadingList(id: UUID(), name: name, createdAt: Date(), iconName: nil, notes: nil)
    }
}
