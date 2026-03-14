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
                            Picker("Libro", selection: $viewModel.selectedBookId) {
                                Text("Selecciona un libro").tag(nil as UUID?)
                                ForEach(viewModel.books, id: \.id) { book in
                                    Text(book.title).tag(book.id as UUID?)
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
                }
            }
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
                        Task {
                            await viewModel.save()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving || viewModel.isLoading)
                }
            }
            .alert("Eliminar cita", isPresented: $showDeleteConfirmation) {
                Button("Eliminar", role: .destructive) {
                    Task {
                        await viewModel.deleteQuote()
                        if viewModel.errorMessage == nil {
                            onDelete?()
                            dismiss()
                        }
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Seguro que quieres eliminar esta cita?")
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
}

private struct PreviewDeleteQuoteForQuoteUseCase: DeleteQuoteUseCaseProtocol {
    func execute(quoteId: UUID) async throws {}
}
