//
//  BookQuotesListView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI
import Observation

/// Lista de citas de un libro; se navega desde la vista "Por libro".
struct BookQuotesListView: View {
    let bookId: UUID
    @Bindable var viewModel: QuotesViewModel
    let container: AppDIContainer

    @State private var pendingDeleteQuoteId: UUID?
    @State private var deleteTrigger = 0

    private var book: Book? {
        viewModel.books.first { $0.id == bookId }
    }

    private var quotes: [Quote] {
        viewModel.quotes(forBookId: bookId)
    }

    var body: some View {
        Group {
            if quotes.isEmpty {
                ContentUnavailableView(
                    "Sin citas en este libro",
                    systemImage: "quote.closing",
                    description: Text("Las citas de este libro aparecerán aquí.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(quotes, id: \.id) { quote in
                        NavigationLink(value: QuotesRoute.quoteDetail(quoteId: quote.id)) {
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
                .listStyle(.insetGrouped)
            }
        }
        .background(Color.theme.mainBackground)
        .navigationTitle(book?.title ?? "Citas")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: deleteTrigger) {
            if deleteTrigger > 0, let id = pendingDeleteQuoteId {
                await viewModel.deleteQuote(quoteId: id)
                pendingDeleteQuoteId = nil
            }
        }
    }
}
