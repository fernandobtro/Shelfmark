//
//  BookDetailView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import SwiftUI
import Observation
import Kingfisher

struct BookDetailView: View {
    @Bindable var viewModel: BookDetailViewModel
    @Environment(\.dismiss) private var dismiss
    let container: AppDIContainer
    @State private var bookToEdit: Book?
    @State private var isShowingDeleteAlert = false
    @State private var isDeleting = false
    @State private var retryTrigger = 0
    @State private var deleteTrigger = 0

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
        .task(id: retryTrigger) {
            await viewModel.loadDetail()
        }
        .task(id: deleteTrigger) {
            if deleteTrigger > 0 {
                await viewModel.delete()
                await MainActor.run { isDeleting = false }
                dismiss()
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

                // Chips de acciones principales
                HStack(spacing: 12) {
                    Label(book.isFavorite ? "Favorito" : "Marcar favorito",
                          systemImage: book.isFavorite ? "heart.fill" : "heart")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color.theme.secondaryBackground)
                        )

                    Label(readingStatusDisplayName(book.readingStatus), systemImage: "book")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color.theme.secondaryBackground)
                        )

                    Button {
                        bookToEdit = book
                    } label: {
                        Label("Editar", systemImage: "pencil")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(Color.theme.secondaryBackground)
                            )
                    }
                    .buttonStyle(.plain)
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mi biblioteca")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 4) {
                            detailRow(title: "Favorito", value: book.isFavorite ? "Sí" : "No")
                            detailRow(title: "Estado", value: readingStatusDisplayName(book.readingStatus))
                        }
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

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Reintentar") {
                retryTrigger += 1
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
        readingStatus: .none
    )

    NavigationStack {
        BookDetailView(
            viewModel: BookDetailViewModel(
                bookId: sampleBook.id,
                fetchBookDetailUseCase: MockFetchBookDetailUseCase(book: sampleBook),
                deleteBookUseCase: MockDeleteBookUseCase()
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
            deleteBookUseCase: MockDeleteBookUseCase()
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
