//
//  BookDetailView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import SwiftUI
import Observation

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
            case .idle:
                Color.clear
            case .loading:
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let book):
                bookContent(book: book)
            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Detalle del libro")
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
        Form {
            Section("Información del libro") {
                LabeledContent("Título", value: book.title)
                if let subtitle = book.subtitle, !subtitle.isEmpty {
                    LabeledContent("Subtítulo", value: subtitle)
                }
            }

            Section("Autores") {
                if book.authors.isEmpty {
                    Text("Sin autores")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(book.authors, id: \.id) { author in
                        Text(author.name)
                    }
                }
            }

            Section("Detalles") {
                LabeledContent("ISBN", value: book.isbn)
                if let publisher = book.publisher {
                    LabeledContent("Editorial", value: publisher.name)
                }
                if let pages = book.numberOfPages {
                    LabeledContent("Páginas", value: "\(pages)")
                }
                if let date = book.publicationDate {
                    LabeledContent("Fecha de publicación", value: date.formatted(date: .abbreviated, time: .omitted))
                }
                LabeledContent("Idioma", value: book.language)
            }

            if let description = book.bookDescription, !description.isEmpty {
                Section("Descripción") {
                    Text(description)
                }
            }

            Section("Mi biblioteca") {
                LabeledContent("Favorito", value: book.isFavorite ? "Sí" : "No")
                LabeledContent("Estado", value: readingStatusDisplayName(book.readingStatus))
            }

            Section {
                Button(role: .destructive) {
                    isShowingDeleteAlert = true
                } label: {
                    if isDeleting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Eliminar libro")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
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
