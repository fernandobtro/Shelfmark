//
//  AuthorQuotesListView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: List screen showing quotes grouped under a selected author.
//

import SwiftUI
import Observation

/// Displays author-scoped quote results and supports navigation to quote detail.
struct AuthorQuotesListView: View {
    let authorName: String
    @Bindable var viewModel: QuotesViewModel
    let container: AppDIContainer

    @State private var pendingDeleteQuoteId: UUID?
    @State private var deleteTrigger = 0

    private var quotes: [Quote] {
        viewModel.quotes(forAuthor: authorName)
    }

    var body: some View {
        Group {
            if quotes.isEmpty {
                ContentUnavailableView(
                    "Sin citas",
                    systemImage: "quote.closing",
                    description: Text("Las citas de este autor aparecerán aquí.")
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
        .navigationTitle(authorName)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: deleteTrigger) {
            if deleteTrigger > 0, let id = pendingDeleteQuoteId {
                await viewModel.deleteQuote(quoteId: id)
                pendingDeleteQuoteId = nil
            }
        }
    }
}
