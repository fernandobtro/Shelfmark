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

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando citas…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                if viewModel.sectionedQuotes.isEmpty {
                    ContentUnavailableView(
                        "Sin citas",
                        systemImage: "quote.closing",
                        description: Text("Añade citas con el botón de la barra.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(Array(viewModel.sectionedQuotes.enumerated()), id: \.offset) { _, section in
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
                                            Task { await viewModel.deleteQuote(quoteId: quote.id) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
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
        .navigationTitle("Citas")
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
}

private struct PreviewFetchLibraryUseCase: FetchLibraryUseCaseProtocol {
    let books: [Book]
    func execute() async throws -> [Book] { books }
}

private struct PreviewDeleteQuoteUseCase: DeleteQuoteUseCaseProtocol {
    func execute(quoteId: UUID) async throws {}
}
