//
//  LibraryView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI
import Foundation
import Observation

struct LibraryView: View {
    
    @Bindable var viewModel: LibraryViewModel

    var body: some View {
        Group {
            switch viewModel.state {

            case .idle:
                Color.clear

            case .loading:
                ProgressView("Cargando biblioteca…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                libraryContent()

            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Biblioteca")
        .safeAreaInset(edge: .top) {
            LibraryHeaderView(viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isShowingSortMenu = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingSortMenu) {
            LibrarySortMenuView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.loadLibrary()
        }
    }

    @ViewBuilder
    private func libraryContent() -> some View {
        if viewModel.sectionedBooks.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "book.closed")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Text("Sin libros")
                    .font(.headline)

                Text("Añade tu primer libro desde el escáner o el formulario.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            LibraryGridView(
                sections: viewModel.sectionedBooks,
                onDelete: { bookId in
                    Task { await viewModel.delete(bookId: bookId) }
                }
            )
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Reintentar") {
                Task {
                    await viewModel.loadLibrary()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

