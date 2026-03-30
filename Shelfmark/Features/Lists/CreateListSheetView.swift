//
//  CreateListSheetView.swift
//  Shelfmark
//
//  Sheet to create a new reading list, presented from `RootView` when tapping + in the Lists tab.
//
//  Purpose: Sheet form used to create a new reading list from the Lists tab.
//

import SwiftUI
import Observation

/// Collects a list name and dispatches creation through `ListsViewModel`.
struct CreateListSheetView: View {
    @Bindable var viewModel: ListsViewModel
    var onDismiss: () -> Void
    @State private var createTrigger = 0
    @FocusState private var isNameFieldFocused: Bool

    private var trimmedName: String {
        viewModel.newListName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Nombre de la lista")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    TextField("Ej. Lecturas de abril", text: $viewModel.newListName)
                        .accessibilityIdentifier("lists.create.nameField")
                        .focused($isNameFieldFocused)
                        .textInputAutocapitalization(.sentences)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.theme.secondaryBackground.opacity(0.72))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                    if let message = viewModel.inputErrorMessage, !message.isEmpty {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.theme.secondaryBackground.opacity(0.72))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.red.opacity(0.28), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTapOutside()
            .background(Color.theme.mainBackground)
            .navigationTitle("Nueva lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        viewModel.newListName = ""
                        viewModel.inputErrorMessage = nil
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        createTrigger += 1
                    }
                    .accessibilityIdentifier("lists.create.confirmButton")
                    .disabled(trimmedName.isEmpty)
                }
            }
            .task(id: createTrigger) {
                if createTrigger > 0 {
                    await viewModel.createList()
                    if viewModel.inputErrorMessage == nil {
                        onDismiss()
                    }
                }
            }
            .task {
                await MainActor.run {
                    isNameFieldFocused = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = ListsViewModel(
        fetchReadingListsUseCase: PreviewCreateListFetchUseCase(),
        createReadingListUseCase: PreviewCreateListCreateUseCase(),
        fetchBooksInListUseCase: PreviewCreateListBooksInListUseCase(),
        renameReadingListUseCase: PreviewCreateListRenameUseCase(),
        deleteReadingListUseCase: PreviewCreateListDeleteUseCase()
    )
    return CreateListSheetView(viewModel: vm, onDismiss: {})
}

private struct PreviewCreateListFetchUseCase: FetchReadingListUseCaseProtocol {
    func execute() async throws -> [ReadingList] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList] { [] }
}

private struct PreviewCreateListBooksInListUseCase: FetchBooksInListUseCaseProtocol {
    func execute(listId: UUID) async throws -> [Book] { [] }
}

private struct PreviewCreateListRenameUseCase: RenameReadingListUseCaseProtocol {
    func execute(id: UUID, newName: String) async throws {}
}

private struct PreviewCreateListDeleteUseCase: DeleteReadingListUseCaseProtocol {
    func execute(id: UUID) async throws {}
}

private struct PreviewCreateListCreateUseCase: CreateReadingListUseCaseProtocol {
    func execute(name: String) async throws -> ReadingList {
        ReadingList(id: UUID(), name: name, createdAt: Date(), iconName: nil, notes: nil)
    }
}
