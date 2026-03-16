//
//  AddEditBookView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import SwiftUI
import Observation

struct AddEditBookView: View {
    @Bindable var viewModel: AddEditBookViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var saveTrigger = 0

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

                Section("Estado") {
                    Toggle("Favorito", isOn: $viewModel.isFavorite)
                    Picker("Estado", selection: $viewModel.readingStatus) {
                        ForEach(ReadingStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTapOutside()
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTrigger += 1
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .task(id: saveTrigger) {
                if saveTrigger > 0 {
                    await viewModel.save()
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Nuevo libro") {
    let vm = AddEditBookViewModel(mode: .add, saveBookUseCase: PreviewSaveBookUseCase())
    return AddEditBookView(viewModel: vm)
}

#Preview("Editar libro") {
    let vm = AddEditBookViewModel(mode: .edit(existing: PreviewHelpers.previewBook1), saveBookUseCase: PreviewSaveBookUseCase())
    return AddEditBookView(viewModel: vm)
}

private struct PreviewSaveBookUseCase: SaveBookUseCaseProtocol {
    func execute(_ book: Book) async throws {}
}

