//
//  AddEditBookView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import SwiftUI

struct AddEditBookView: View {
    @ObservedObject var viewModel: AddEditBookViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Información del libro") {
                    TextField("Título", text: $viewModel.title)
                    TextField("Subtítulo", text: $viewModel.subtitle)
                }

                Section("Autores") {
                    TextField("Autor(es), separados por comas", text: $viewModel.authorsText)
                }

                Section("Detalles") {
                    TextField("ISBN", text: $viewModel.isbn)
                    TextField("Editorial", text: $viewModel.publisherName)
                    TextField("Número de páginas", text: $viewModel.pagesText)
                        .keyboardType(.numberPad)

                    DatePicker(
                        "Fecha de publicación",
                        selection: Binding(
                            get: { viewModel.publicationDate ?? Date() },
                            set: { viewModel.publicationDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .opacity(viewModel.publicationDate == nil ? 0.6 : 1)

                    TextField("Idioma (código, ej. es, en)", text: $viewModel.language)
                }

                Section("Descripción") {
                    TextField("Descripción", text: $viewModel.descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task {
                            await viewModel.save()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }
}

// MARK: - Preview

private struct MockSaveBookUseCase: SaveBookUseCaseProtocol {
    func execute(_ book: Book) async throws {}
}

#Preview("Añadir libro") {
    AddEditBookView(
        viewModel: AddEditBookViewModel(
            mode: .add,
            saveBookUseCase: MockSaveBookUseCase()
        )
    )
}

#Preview("Editar libro") {
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
    AddEditBookView(
        viewModel: AddEditBookViewModel(
            mode: .edit(existing: sampleBook),
            saveBookUseCase: MockSaveBookUseCase()
        )
    )
}
