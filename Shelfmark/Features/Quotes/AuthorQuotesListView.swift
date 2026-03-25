//
//  AuthorQuotesListView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI
import Observation

/// Lista de citas de un autor; se navega desde la vista "Por autor".
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
