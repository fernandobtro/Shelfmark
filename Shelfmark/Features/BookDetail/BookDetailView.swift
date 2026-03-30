//
//  BookDetailView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Book detail screen showing metadata, reading progress actions, and related quote entry points.
//

import SwiftUI
import Observation
import Kingfisher

/// Renders detail state and dispatches edit/delete/progress actions to the view model.
struct BookDetailView: View {
    @Bindable var viewModel: BookDetailViewModel
    @Environment(\.dismiss) private var dismiss
    let container: AppDIContainer
    @State private var bookToEdit: Book?
    @State private var bookForNewQuote: Book?
    @State private var isShowingDeleteAlert = false
    @State private var isDeleting = false
    @State private var retryTrigger = 0
    @State private var deleteTrigger = 0
    @State private var currentPageDraft = ""

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let book):
                bookContent(book: book)
            case .error(let message):
                errorView(message: message)
            }
        }
        .background(Color.theme.mainBackground)
        .dismissKeyboardOnTapOutside()
        .navigationTitle("Ficha del libro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") {
                    bookToEdit = viewModel.loadedBook
                }
                .disabled(viewModel.loadedBook == nil)
            }
        }
        .sheet(item: $bookToEdit, onDismiss: {
            retryTrigger += 1
        }) { book in
            container.makeAddEditBookView(mode: .edit(existing: book))
        }
        .sheet(item: $bookForNewQuote) { book in
            NavigationStack {
                AddEditQuoteView(
                    viewModel: container.makeAddEditQuoteViewModel(mode: .addForBook(book)),
                    onDelete: nil
                )
            }
        }
        .task(id: retryTrigger) {
            await viewModel.loadDetail()
        }
        .task(id: deleteTrigger) {
            if deleteTrigger > 0 {
                let didDelete = await viewModel.delete()
                await MainActor.run { isDeleting = false }
                if didDelete {
                    dismiss()
                }
            }
        }
    }

    private func bookContent(book: Book) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Portada centrada
                if let url = book.thumbnailURL {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 220)
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                        .padding(.top, 24)
                }

                // Título y autor
                VStack(spacing: 6) {
                    Text(book.title)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)

                    if let subtitle = book.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    let authorsText = book.authors.map(\.name).joined(separator: ", ")
                    if !authorsText.isEmpty {
                        Text(authorsText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            Task { await viewModel.toggleFavorite() }
                        } label: {
                            Label(book.isFavorite ? "Favorito" : "Marcar favorito",
                                  systemImage: book.isFavorite ? "heart.fill" : "heart")
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(chipBackground)
                                .overlay(chipBorder)
                        }
                        .buttonStyle(.plain)

                        Menu {
                            ForEach(ReadingStatus.allCases, id: \.self) { status in
                                Button(status.displayName) {
                                    Task { await viewModel.setReadingStatus(status) }
                                }
                            }
                        } label: {
                            Label(readingStatusDisplayName(book.readingStatus), systemImage: "book")
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(chipBackground)
                                .overlay(chipBorder)
                        }

                        Button {
                            bookToEdit = book
                        } label: {
                            Label("Editar", systemImage: "pencil")
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(chipBackground)
                                .overlay(chipBorder)
                        }
                        .buttonStyle(.plain)

                        Button {
                            bookForNewQuote = book
                        } label: {
                            Label("Añadir cita", systemImage: "quote.bubble")
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(chipBackground)
                                .overlay(chipBorder)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .foregroundStyle(Color.theme.textPrimary)
                .padding(.horizontal)

                // Detalles
                VStack(alignment: .leading, spacing: 16) {
                    if let description = book.bookDescription, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .detailCard()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detalles")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 4) {
                            detailRow(title: "ISBN", value: book.isbn)
                            if let publisher = book.publisher {
                                detailRow(title: "Editorial", value: publisher.name)
                            }
                            if let pages = book.numberOfPages {
                                detailRow(title: "Páginas", value: "\(pages)")
                            }
                            if let date = book.publicationDate {
                                detailRow(title: "Fecha de publicación", value: date.formatted(date: .abbreviated, time: .omitted))
                            }
                            detailRow(title: "Idioma", value: book.language)
                        }
                    }
                    .detailCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mi biblioteca")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 4) {
                            detailRow(title: "Favorito", value: book.isFavorite ? "Sí" : "No")
                            detailRow(title: "Estado", value: readingStatusDisplayName(book.readingStatus))
                            if let p = book.currentPage {
                                detailRow(title: "Página actual", value: "\(p)")
                            }
                        }
                    }
                    .detailCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progreso de lectura")
                            .font(.headline)

                        HStack(spacing: 8) {
                            Button("Reiniciar progreso") {
                                Task { await viewModel.resetProgress() }
                            }
                            .buttonStyle(.bordered)

                            Button("Marcar como leído") {
                                Task { await viewModel.markAsCompleted() }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.primaryGreen)

                            Button("Volver a pendiente") {
                                Task { await viewModel.markAsPending() }
                            }
                            .buttonStyle(.bordered)
                        }

                        HStack(spacing: 8) {
                            TextField("Página actual", text: $currentPageDraft)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)

                            Button("Guardar") {
                                Task { await viewModel.saveCurrentPage(from: currentPageDraft) }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.primaryGreen)
                        }

                        if let err = viewModel.quickSaveError, !err.isEmpty {
                            Text(err)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        if let frac = book.readingProgressFraction,
                           let cur = book.currentPage,
                           let total = book.numberOfPages {
                            ProgressView(value: frac, total: 1.0)
                            Text("\(min(max(cur, 1), total)) / \(total) páginas")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .detailCard()

                    if !viewModel.quotesForBook.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Citas de este libro")
                                .font(.headline)

                            let quotes = viewModel.quotesForBook
                            let count = quotes.count

                            Text(count == 1 ? "1 cita guardada" : "\(count) citas guardadas")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(quotes.prefix(3), id: \.id) { quote in
                                    Text("“\(quote.text)”")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }
                            }

                            NavigationLink(value: QuotesRoute.bookQuotes(bookId: book.id)) {
                                Text("Ver todas las citas de este libro")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .detailCard()
                    }
                }
                .padding(.horizontal)

                // Botón eliminar
                Button(role: .destructive) {
                    isShowingDeleteAlert = true
                } label: {
                    if isDeleting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Eliminar libro")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.horizontal)
                .padding(.bottom, 24)
                .disabled(isDeleting)
            }
        }
        .alert("Eliminar libro", isPresented: $isShowingDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                isDeleting = true
                deleteTrigger += 1
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción eliminará el libro de tu biblioteca. No se puede deshacer.")
        }
        .onAppear {
            currentPageDraft = book.currentPage.map(String.init) ?? ""
        }
        .onChange(of: book) { _, newBook in
            currentPageDraft = newBook.currentPage.map(String.init) ?? ""
        }
    }

    private func readingStatusDisplayName(_ status: ReadingStatus) -> String {
        switch status {
        case .pending: return "Pendiente"
        case .reading: return "Leyendo"
        case .read: return "Leído"
        case .none: return "Ninguno"
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(Color.theme.textPrimary)
        }
        .font(.footnote)
    }

    private var chipBackground: some View {
        Capsule(style: .continuous)
            .fill(Color.theme.secondaryBackground.opacity(0.72))
    }

    private var chipBorder: some View {
        Capsule(style: .continuous)
            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
    }

    private func errorView(message: String) -> some View {
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

private extension View {
    func detailCard() -> some View {
        self
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.theme.secondaryBackground.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

#Preview("Con libro") {
    let container = AppDIContainer()

    let sampleBook = Book(
        id: UUID(),
        isbn: "978-84-206-4750-0",
        authors: [Author(id: UUID(), name: "J.R.R. Tolkien")],
        title: "El Hobbit",
        numberOfPages: 366,
        publisher: Publisher(id: UUID(), name: "Minotauro"),
        publicationDate: Date(),
        thumbnailURL: nil,
        bookDescription: "Un clásico de la fantasía.",
        subtitle: "O ida y vuelta",
        language: "es",
        isFavorite: false,
        readingStatus: .none,
        currentPage: 42
    )

    NavigationStack {
        BookDetailView(
            viewModel: BookDetailViewModel(
                bookId: sampleBook.id,
                fetchBookDetailUseCase: MockFetchBookDetailUseCase(book: sampleBook),
                deleteBookUseCase: MockDeleteBookUseCase(),
                fetchQuotesUseCase: MockFetchQuotesUseCase(quotes: []),
                saveBookUseCase: MockSaveBookUseCase()
            ),
            container: container
        )
    }
}

#Preview("Cargando") {
    let container = AppDIContainer()

    struct PreviewWrapper: View {
        let container: AppDIContainer

        @State private var viewModel = BookDetailViewModel(
            bookId: UUID(),
                fetchBookDetailUseCase: MockFetchBookDetailUseCase(book: nil),
                deleteBookUseCase: MockDeleteBookUseCase(),
                fetchQuotesUseCase: MockFetchQuotesUseCase(quotes: []),
                saveBookUseCase: MockSaveBookUseCase()
        )

        var body: some View {
            NavigationStack {
                BookDetailView(viewModel: viewModel, container: container)
            }
        }
    }

    return PreviewWrapper(container: container)
}


private struct MockFetchBookDetailUseCase: FetchBookDetailUseCaseProtocol {
    let book: Book?

    func execute(bookId: UUID) async throws -> Book? {
        book
    }
}

private struct MockDeleteBookUseCase: DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws { }
}

private struct MockFetchQuotesUseCase: FetchQuotesUseCaseProtocol {
    let quotes: [Quote]

    func execute() async throws -> [Quote] { quotes }
    func executePaginated(limit: Int, offset: Int) async throws -> [Quote] {
        Array(quotes.dropFirst(offset).prefix(limit))
    }
}

private struct MockSaveBookUseCase: SaveBookUseCaseProtocol {
    func execute(_ book: Book) async throws {}
}
