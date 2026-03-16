//
//  QuotesView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import SwiftUI
import Observation

struct QuotesView: View {
    @Bindable var viewModel: QuotesViewModel
    let container: AppDIContainer
    @State private var pendingDeleteQuoteId: UUID?
    @State private var deleteTrigger = 0

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando citas…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                if viewModel.filteredSectionedQuotes.isEmpty {
                    ContentUnavailableView(
                        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Sin citas" : "Ningún resultado",
                        systemImage: viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "quote.closing" : "magnifyingglass",
                        description: Text(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Añade citas con el botón de la barra." : "Prueba con otro término.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(Array(viewModel.filteredSectionedQuotes.enumerated()), id: \.offset) { _, section in
                            Section(section.key) {
                                ForEach(section.quotes, id: \.id) { quote in
                                    NavigationLink(value: quote.id) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(quote.text)
                                                .lineLimit(3)
                                            if let page = quote.pageReference, !page.isEmpty {
                                                Text("P. \(page)")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                    .contextMenu {
                                        Button("Eliminar", role: .destructive) {
                                            pendingDeleteQuoteId = quote.id
                                            deleteTrigger += 1
                                        }
                                    }
                                }
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
                    .listStyle(.insetGrouped)
                    .scrollDismissesKeyboard(.interactively)
                    .task(id: deleteTrigger) {
                        if deleteTrigger > 0, let id = pendingDeleteQuoteId {
                            await viewModel.deleteQuote(quoteId: id)
                            pendingDeleteQuoteId = nil
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
        .background(Color.theme.mainBackground)
        .navigationTitle("Citas")
        .searchable(text: $viewModel.searchText, prompt: "Buscar por libro, autor o texto")
        .safeAreaInset(edge: .top, spacing: 0) {
            Picker("Agrupar", selection: Binding(
                get: { viewModel.grouping },
                set: { viewModel.setGrouping($0) }
            )) {
                Text("Por libro").tag(QuotesViewModel.Grouping.byBook)
                Text("Por autor").tag(QuotesViewModel.Grouping.byAuthor)
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .dismissKeyboardOnTapOutside()
        .task {
            await viewModel.loadQuotes()
        }
    }
}

// MARK: - Previews

#Preview("Con citas") {
    let bookId = UUID()
    let quotes = [
        Quote(id: UUID(), text: "Hallamos en esa tarde de domingo un espacio que permitía la felicidad.", bookId: bookId, pageReference: "27", createdAt: Date()),
        Quote(id: UUID(), text: "La memoria es un espejo que nos miente.", bookId: bookId, pageReference: nil, createdAt: Date()),
    ]
    let books = [
        Book(id: bookId, isbn: "978-0-00-000000-0", authors: [Author(id: UUID(), name: "José Emilio Pacheco")], title: "El viento distante", numberOfPages: nil, publisher: nil, publicationDate: nil, thumbnailURL: nil, bookDescription: nil, subtitle: nil, language: "es", isFavorite: false, readingStatus: .none),
    ]
    let vm = QuotesViewModel(
        fetchQuotesUseCase: PreviewFetchQuotesUseCase(quotes: quotes),
        fetchLibraryUseCase: PreviewFetchLibraryUseCase(books: books),
        deleteQuoteUseCase: PreviewDeleteQuoteUseCase()
    )
    return NavigationStack {
        QuotesView(viewModel: vm, container: AppDIContainer())
            .task { await vm.loadQuotes() }
    }
}

#Preview("Sin citas") {
    let vm = QuotesViewModel(
        fetchQuotesUseCase: PreviewFetchQuotesUseCase(quotes: []),
        fetchLibraryUseCase: PreviewFetchLibraryUseCase(books: []),
        deleteQuoteUseCase: PreviewDeleteQuoteUseCase()
    )
    return NavigationStack {
        QuotesView(viewModel: vm, container: AppDIContainer())
            .task { await vm.loadQuotes() }
    }
}

private struct PreviewFetchQuotesUseCase: FetchQuotesUseCaseProtocol {
    let quotes: [Quote]
    func execute() async throws -> [Quote] { quotes }
    func executePaginated(limit: Int, offset: Int) async throws -> [Quote] {
        Array(quotes.dropFirst(offset).prefix(limit))
    }
}

private struct PreviewFetchLibraryUseCase: FetchLibraryUseCaseProtocol {
    let books: [Book]
    func execute() async throws -> [Book] { books }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] {
        Array(books.dropFirst(offset).prefix(limit))
    }
}

private struct PreviewDeleteQuoteUseCase: DeleteQuoteUseCaseProtocol {
    func execute(quoteId: UUID) async throws {}
}
