//
//  QuoteDetailView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Quote detail screen with linked book metadata and edit/delete actions.
//

import SwiftUI
import Observation

/// Displays quote content and routes edit/delete/navigation actions.
struct QuoteDetailView: View {
    @Bindable var viewModel: QuoteDetailViewModel
    let container: AppDIContainer
    @Environment(\.dismiss) private var dismiss

    @State private var isPresentingEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var loadTrigger = 0
    @State private var deleteTrigger = 0

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let quote, let book):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Texto", systemImage: "quote.opening")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            Text(quote.text)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.theme.secondaryBackground.opacity(0.72))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        if let b = book {
                            let authorName = b.authors.map(\.name).joined(separator: ", ")
                            let pageStr = quote.pageReference.map { " P. \($0)." } ?? "."
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Referencia", systemImage: "book.closed")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)

                                Text("— \(authorName), \(b.title).\(pageStr)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                NavigationLink(value: QuotesRoute.bookDetail(bookId: b.id)) {
                                    Label("Abrir libro", systemImage: "book")
                                        .font(.subheadline.weight(.semibold))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.theme.secondaryBackground.opacity(0.72))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        } else if let page = quote.pageReference, !page.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Página", systemImage: "bookmark")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Text("P. \(page)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.theme.secondaryBackground.opacity(0.72))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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
        .background(Color.theme.mainBackground)
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
                deleteTrigger += 1
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("¿Seguro que quieres eliminar esta cita?")
        }
        .navigationDestination(isPresented: $isPresentingEditSheet) {
            AddEditQuoteView(
                viewModel: container.makeAddEditQuoteViewModel(mode: .edit(quoteId: viewModel.quoteId)),
                onDelete: nil
            )
        }
        .onChange(of: isPresentingEditSheet) { _, isPresenting in
            if !isPresenting { loadTrigger += 1 }
        }
        .onChange(of: viewModel.state) { _, newState in
            if case .deleted = newState {
                dismiss()
            }
        }
        .task(id: loadTrigger) {
            await viewModel.load()
        }
        .task(id: deleteTrigger) {
            if deleteTrigger > 0 {
                await viewModel.deleteQuote()
            }
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
