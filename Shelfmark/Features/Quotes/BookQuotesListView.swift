//
//  BookQuotesListView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: List screen showing quotes associated with a selected book.
//

import SwiftUI
import Observation

/// Displays book-scoped quotes and supports navigation to quote detail.
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
                        .contextMenu {
                            Button("Eliminar", role: .destructive) {
                                pendingDeleteQuoteId = quote.id
                                deleteTrigger += 1
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
