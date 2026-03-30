//
//  AddBooksToListSheet.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Sheet that lists candidate books and adds selected entries into a reading list.
//

import SwiftUI

/// Supports add-to-list flow by presenting selectable library books.
struct AddBooksToListSheet: View {
    let fetchLibraryUseCase: FetchLibraryUseCaseProtocol
    let bookIdsAlreadyInList: Set<UUID>
    let onAddBook: (UUID) async -> Void
    let onDismiss: () -> Void

    enum SheetState {
        case loading
        case loaded([Book])
        case error(String)
    }

    @State private var sheetState: SheetState = .loading
    @State private var searchText: String = ""
    @State private var addTrigger = 0
    @State private var bookIdToAdd: UUID?
    @State private var retryTrigger = 0
    @State private var addedThisSession: Set<UUID> = []

    private var booksToShow: [Book] {
        guard case .loaded(let books) = sheetState else { return [] }
        let available = books
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return available }
        let normalized = query.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current)
        return available.filter { book in
            book.title.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(normalized)
            || book.authors.contains { $0.name.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(normalized) }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch sheetState {
                case .loading:
                    ProgressView("Cargando biblioteca…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded:
                    if booksToShow.isEmpty {
                        ContentUnavailableView(
                            "Nada que añadir",
                            systemImage: "checkmark.circle",
                            description: Text("Todos los libros de tu biblioteca ya están en esta lista.")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(booksToShow, id: \.id) { book in
                                let isAlreadyInList = bookIdsAlreadyInList.contains(book.id)
                                let isSelected = isAlreadyInList || addedThisSession.contains(book.id)

                                Button {
                                    guard !isSelected else { return }
                                    bookIdToAdd = book.id
                                    addTrigger += 1
                                } label: {
                                    HStack {
                                        addBookRow(book: book)
                                            .opacity(isSelected ? 0.6 : 1.0)

                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.primaryGreen)
                                        }
                                    }
                                }
                                .disabled(isSelected)
                                .buttonStyle(.plain)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .scrollDismissesKeyboard(.interactively)
                        .task(id: addTrigger) {
                            if addTrigger > 0, let id = bookIdToAdd {
                                await onAddBook(id)
                                await MainActor.run {
                                    addedThisSession.insert(id)
                                    bookIdToAdd = nil
                                }
                            }
                        }
                    }

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
            .navigationTitle("Añadir a la lista")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar por título o autor")
            .dismissKeyboardOnTapOutside()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(readyButtonTitle) {
                        onDismiss()
                    }
                    .animation(.default, value: addedThisSession.count)
                }
            }
            .task(id: retryTrigger) {
                await loadLibrary()
            }
        }
    }

    private func loadLibrary() async {
        sheetState = .loading
        do {
            let books = try await fetchLibraryUseCase.execute()
            await MainActor.run {
                sheetState = .loaded(books)
            }
        } catch {
            await MainActor.run {
                sheetState = .error(UserFacingError.message(error, fallback: "No se pudieron cargar los libros. Intenta de nuevo."))
            }
        }
    }

    private var readyButtonTitle: String {
        guard !addedThisSession.isEmpty else { return "Listo" }
        return "Listo (\(addedThisSession.count))"
    }

    @ViewBuilder
    private func addBookRow(book: Book) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.theme.secondaryBackground.opacity(0.85))

                if let url = book.thumbnailURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.clear
                    }
                } else {
                    Image(systemName: "book.closed")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 40, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .foregroundStyle(Color.theme.textPrimary)

                let authors = book.authors.map(\.name).joined(separator: ", ")
                if !authors.isEmpty {
                    Text(authors)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.theme.secondaryBackground.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Añadir libros (con datos mock)") {
    AddBooksToListSheet(
        fetchLibraryUseCase: PreviewAddBooksFetchUseCase(),
        bookIdsAlreadyInList: [],
        onAddBook: { _ in },
        onDismiss: {}
    )
}

private struct PreviewAddBooksFetchUseCase: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { PreviewHelpers.previewBooks }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] {
        Array(PreviewHelpers.previewBooks.dropFirst(offset).prefix(limit))
    }
}
