//
//  AddEditQuoteView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Quote form screen for create/edit flows with optional scanner-prefilled text.
//

import SwiftUI
import Observation
import UIKit

/// Collects quote text, book selection, and save/delete actions.
struct AddEditQuoteView: View {
    @Bindable var viewModel: AddEditQuoteViewModel
    @Environment(\.dismiss) private var dismiss
    var onDelete: (() -> Void)?

    @State private var showDeleteConfirmation = false
    @State private var saveTrigger = 0
    @State private var deleteTrigger = 0
    @State private var showBookSelector = false
    @FocusState private var isQuoteTextFieldFocused: Bool

    private var isInteractionLocked: Bool {
        viewModel.isSaving || viewModel.isLoading
    }

    private var isSaveDisabled: Bool {
        isInteractionLocked
        || viewModel.selectedBookId == nil
        || viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Form {
                    Section("Cita") {
                        fieldCard {
                            TextField("Texto de la cita", text: $viewModel.text, axis: .vertical)
                                .lineLimit(5...10)
                                .focused($isQuoteTextFieldFocused)
                                .accessibilityIdentifier("quote.form.text")
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    Section("Libro") {
                        fieldCard {
                            if viewModel.isBookLocked {
                                // Book pre-selected by caller; display as static, non-interactive row.
                                HStack {
                                    if let book = viewModel.selectedBook {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(book.title)
                                                .font(.body.weight(.semibold))
                                                .foregroundStyle(.primary)
                                            let authors = book.authors.map(\.name).joined(separator: ", ")
                                            if !authors.isEmpty {
                                                Text(authors)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    } else {
                                        Text("Cargando libro…")
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Button {
                                    isQuoteTextFieldFocused = false
                                    UIApplication.shared.sendAction(
                                        #selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil
                                    )
                                    showBookSelector = true
                                } label: {
                                    HStack {
                                        if let book = viewModel.selectedBook {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(book.title)
                                                    .font(.body.weight(.semibold))
                                                    .foregroundStyle(.primary)
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
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .accessibilityIdentifier("quote.form.selectBook")
                                .buttonStyle(.plain)
                            }
                        }
                        .disabled(!viewModel.isBookLocked && (viewModel.books.isEmpty || isInteractionLocked))
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    Section("Página (opcional)") {
                        fieldCard {
                            TextField("Ej. 27 o 27-29", text: $viewModel.pageReference)
                                .keyboardType(.numbersAndPunctuation)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    if let error = viewModel.errorMessage {
                        Section {
                            fieldCard {
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }

                    if viewModel.isEditMode {
                        Section {
                            fieldCard {
                                Button("Eliminar cita", role: .destructive) {
                                    showDeleteConfirmation = true
                                }
                                .disabled(isInteractionLocked)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .dismissKeyboardOnTapOutside()
        .background(Color.theme.mainBackground)
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
                .disabled(isInteractionLocked)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    saveTrigger += 1
                } label: {
                    if viewModel.isSaving {
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Guardando…")
                        }
                    } else {
                        Text("Guardar")
                    }
                }
                .accessibilityIdentifier("quote.form.save")
                .disabled(isSaveDisabled)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if viewModel.isSaving {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Guardando cita…")
                        .font(.footnote.weight(.semibold))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.theme.secondaryBackground.opacity(0.92))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.bottom, 10)
                .transition(.opacity)
            }
        }
        .task(id: saveTrigger) {
            if saveTrigger > 0 {
                await viewModel.save()
                if viewModel.errorMessage == nil {
                    notifyHaptic(.success)
                    dismiss()
                } else {
                    notifyHaptic(.error)
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
        .navigationDestination(isPresented: $showBookSelector) {
            SelectBookForQuoteSheetView(
                books: viewModel.books,
                preselectedBookId: viewModel.selectedBookId
            ) { book in
                viewModel.selectedBook = book
            } onClose: {
                showBookSelector = false
            }
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private func fieldCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
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
    }

    private func notifyHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
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
