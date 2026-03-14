//
//  QuoteDetailView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import SwiftUI
import Observation

struct QuoteDetailView: View {
    @Bindable var viewModel: QuoteDetailViewModel
    let container: AppDIContainer
    @Environment(\.dismiss) private var dismiss

    @State private var isPresentingEditSheet = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let quote, let book):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(quote.text)
                            .font(.body)

                        if let b = book {
                            let authorName = b.authors.map(\.name).joined(separator: ", ")
                            let pageStr = quote.pageReference.map { " P. \($0)." } ?? "."
                            Text("— \(authorName), \(b.title).\(pageStr)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else if let page = quote.pageReference, !page.isEmpty {
                            Text("P. \(page)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }

            case .error(let message):
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message.isEmpty ? "Error" : message)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .deleted:
                EmptyView()
            }
        }
        .navigationTitle("Cita")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isPresentingEditSheet = true
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .disabled(!isLoaded)

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    .disabled(!isLoaded)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Eliminar cita", isPresented: $showDeleteConfirmation) {
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.deleteQuote()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("¿Seguro que quieres eliminar esta cita?")
        }
        .sheet(isPresented: $isPresentingEditSheet, onDismiss: {
            Task { await viewModel.load() }
        }) {
            AddEditQuoteView(
                viewModel: container.makeAddEditQuoteViewModel(mode: AddEditQuoteMode.edit(quoteId: viewModel.quoteId)),
                onDelete: { dismiss() }
            )
        }
        .onChange(of: viewModel.state) { _, newState in
            if case .deleted = newState {
                dismiss()
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var isLoaded: Bool {
        if case .loaded = viewModel.state { return true }
        return false
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        QuoteDetailView(
            viewModel: QuoteDetailViewModel(
                quoteId: UUID(),
                fetchQuoteByIdUseCase: PreviewQuoteDetailFetchQuoteUseCase(),
                fetchBookDetailUseCase: PreviewQuoteDetailFetchBookUseCase(),
                deleteQuoteUseCase: PreviewQuoteDetailDeleteUseCase()
            ),
            container: AppDIContainer()
        )
    }
}

private struct PreviewQuoteDetailFetchQuoteUseCase: FetchQuoteByIdUseCaseProtocol {
    func execute(quoteId: UUID) async throws -> Quote? { nil }
}

private struct PreviewQuoteDetailFetchBookUseCase: FetchBookDetailUseCaseProtocol {
    func execute(bookId: UUID) async throws -> Book? { nil }
}

private struct PreviewQuoteDetailDeleteUseCase: DeleteQuoteUseCaseProtocol {
    func execute(quoteId: UUID) async throws {}
}
