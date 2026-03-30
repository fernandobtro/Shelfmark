//
//  QuotesView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Quotes tab screen with by-book/by-author grouping, search, and paginated navigation entry points.
//

import SwiftUI
import Observation

/// Presents grouped quote collections and drives pagination/retry interactions.
struct QuotesView: View {
    @Bindable var viewModel: QuotesViewModel
    let container: AppDIContainer
    @State private var retryTrigger = 0

    private let gridColumns = [GridItem(.adaptive(minimum: 140), spacing: 16)]
    private let emptySearchMessage = "Sin resultados"
    private let emptySearchSuggestion = "Prueba con otra búsqueda."
    private let emptyQuotesMessage = "Sin citas"
    private let emptyQuotesSuggestion = "Añade citas con el botón +."

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando citas…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                mainContent

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
        .navigationTitle("Citas")
        .searchable(text: $viewModel.searchText, prompt: "Buscar por libro, autor o texto")
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                Picker("Agrupar", selection: Binding(
                    get: { viewModel.grouping },
                    set: { viewModel.setGrouping($0) }
                )) {
                    Text("Por libro").tag(QuotesViewModel.Grouping.byBook)
                    Text("Por autor").tag(QuotesViewModel.Grouping.byAuthor)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 10)
            }
            .background(Color.theme.mainBackground.opacity(0.95))
        }
        .dismissKeyboardOnTapOutside()
        .task(id: retryTrigger) {
            await viewModel.loadQuotes()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.grouping {
        case .byBook:
            byBookContent
        case .byAuthor:
            byAuthorContent
        }
    }

    @ViewBuilder
    private var byBookContent: some View {
        let items = viewModel.booksWithQuoteCount
        let isEmpty = items.isEmpty
        let isSearchEmpty = !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if isEmpty {
            ContentUnavailableView(
                isSearchEmpty ? emptySearchMessage : emptyQuotesMessage,
                systemImage: isSearchEmpty ? "magnifyingglass" : "quote.closing",
                description: Text(isSearchEmpty ? emptySearchSuggestion : emptyQuotesSuggestion)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(items, id: \.0.id) { item in
                        NavigationLink(value: QuotesRoute.bookQuotes(bookId: item.0.id)) {
                            QuotesBookCellView(book: item.0, quoteCount: item.1)
                        }
                        .buttonStyle(.plain)
                    }
                    paginationTrigger
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    @ViewBuilder
    private var byAuthorContent: some View {
        let items = viewModel.authorsWithQuoteCount
        let isEmpty = items.isEmpty
        let isSearchEmpty = !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if isEmpty {
            ContentUnavailableView(
                isSearchEmpty ? emptySearchMessage : emptyQuotesMessage,
                systemImage: isSearchEmpty ? "magnifyingglass" : "quote.closing",
                description: Text(isSearchEmpty ? emptySearchSuggestion : emptyQuotesSuggestion)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(items, id: \.name) { item in
                    NavigationLink(value: QuotesRoute.authorQuotes(authorName: item.name)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.headline)
                            Text("\(item.count) \(item.count == 1 ? "cita guardada" : "citas guardadas")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 14)
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
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                paginationSection
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
    }

    @ViewBuilder
    private var paginationTrigger: some View {
        if viewModel.hasMore {
            if viewModel.isLoadingNextPage {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                Color.clear
                    .frame(height: 1)
                    .task { await viewModel.loadNextPage() }
            }
        }
    }

    @ViewBuilder
    private var paginationSection: some View {
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
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .task { await viewModel.loadNextPage() }
                }
            }
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
        Book(id: bookId, isbn: "978-0-00-000000-0", authors: [Author(id: UUID(), name: "José Emilio Pacheco")], title: "El viento distante", numberOfPages: nil, publisher: nil, publicationDate: nil, thumbnailURL: nil, bookDescription: nil, subtitle: nil, language: "es", isFavorite: false, readingStatus: .none, currentPage: nil),
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
