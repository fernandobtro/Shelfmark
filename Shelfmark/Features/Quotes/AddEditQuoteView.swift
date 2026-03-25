//
//  AddEditQuoteView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import SwiftUI
import Observation

struct AddEditQuoteView: View {
    @Bindable var viewModel: AddEditQuoteViewModel
    @Environment(\.dismiss) private var dismiss
    var onDelete: (() -> Void)?

    @State private var showDeleteConfirmation = false
    @State private var saveTrigger = 0
    @State private var deleteTrigger = 0
    @State private var showBookSelector = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Form {
                        Section("Cita") {
                            TextField("Texto de la cita", text: $viewModel.text, axis: .vertical)
                                .lineLimit(5...10)
                        }

                        Section("Libro") {
                            Button {
                                showBookSelector = true
                            } label: {
                                HStack {
                                    if let book = viewModel.selectedBook {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(book.title)
                                                .font(.body)
                                            let authors = book.authors.map(\.name).joined(separator: ", ")
                                            if !authors.isEmpty {
                                                Text(authors)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    } else {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Seleccionar libro")
                                                .foregroundStyle(.primary)
                                            Text("Obligatorio para guardar")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .disabled(viewModel.books.isEmpty)
                        }

                        Section("Página (opcional)") {
                            TextField("Ej. 27 o 27-29", text: $viewModel.pageReference)
                                .keyboardType(.numbersAndPunctuation)
                        }

                        if let error = viewModel.errorMessage {
                            Section {
                                Text(error)
                                    .foregroundStyle(.red)
                            }
                        }

                        if viewModel.isEditMode {
                            Section {
                                Button("Eliminar cita", role: .destructive) {
                                    showDeleteConfirmation = true
                                }
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .dismissKeyboardOnTapOutside()
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTrigger += 1
                    }
                    .disabled(
                        viewModel.isSaving
                        || viewModel.isLoading
                        || viewModel.selectedBookId == nil
                        || viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
            .task(id: saveTrigger) {
                if saveTrigger > 0 {
                    await viewModel.save()
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            }
            .task(id: deleteTrigger) {
                if deleteTrigger > 0 {
                    await viewModel.deleteQuote()
                    if viewModel.errorMessage == nil {
                        onDelete?()
                        dismiss()
                    }
                }
            }
            .alert("Eliminar cita", isPresented: $showDeleteConfirmation) {
                Button("Eliminar", role: .destructive) {
                    deleteTrigger += 1
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Seguro que quieres eliminar esta cita?")
            }
        }
        .sheet(isPresented: $showBookSelector) {
            SelectBookForQuoteSheetView(
                books: viewModel.books,
                preselectedBookId: viewModel.selectedBookId
            ) { book in
                viewModel.selectedBook = book
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Previews

#Preview("Nueva cita") {
    AddEditQuoteView(viewModel: AddEditQuoteViewModel(
        mode: .add,
        saveQuoteUseCase: PreviewSaveQuoteUseCase(),
        fetchQuoteByIdUseCase: PreviewFetchQuoteByIdUseCase(),
        fetchLibraryUseCase: PreviewFetchLibraryForQuoteUseCase(),
        deleteQuoteUseCase: PreviewDeleteQuoteForQuoteUseCase()
    ))
}

#Preview("Editar cita") {
    AddEditQuoteView(viewModel: AddEditQuoteViewModel(
        mode: .edit(quoteId: UUID()),
        saveQuoteUseCase: PreviewSaveQuoteUseCase(),
        fetchQuoteByIdUseCase: PreviewFetchQuoteByIdUseCase(),
        fetchLibraryUseCase: PreviewFetchLibraryForQuoteUseCase(),
        deleteQuoteUseCase: PreviewDeleteQuoteForQuoteUseCase()
    ))
}

private struct PreviewSaveQuoteUseCase: SaveQuoteUseCaseProtocol {
    func execute(quote: Quote) async throws {}
}

private struct PreviewFetchQuoteByIdUseCase: FetchQuoteByIdUseCaseProtocol {
    func execute(quoteId: UUID) async throws -> Quote? { nil }
}

private struct PreviewFetchLibraryForQuoteUseCase: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] { [] }
}

private struct PreviewDeleteQuoteForQuoteUseCase: DeleteQuoteUseCaseProtocol {
    func execute(quoteId: UUID) async throws {}
}
