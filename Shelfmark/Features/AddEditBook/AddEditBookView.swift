//
//  AddEditBookView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import SwiftUI
import Observation
import Kingfisher

struct AddEditBookView: View {
    @Bindable var viewModel: AddEditBookViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var saveTrigger = 0
    @State private var isShowingCoverScanner = false
    @State private var coverProcessingError: String?

    var body: some View {
        NavigationStack {
            Form {
                coverSection

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

                    Picker("Idioma", selection: $viewModel.language) {
                        ForEach(languageOptions) { option in
                            Text(option.displayName).tag(option.code)
                        }
                    }
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
            .sheet(isPresented: $isShowingCoverScanner) {
                CoverDocumentScanner { image in
                    Task {
                        do {
                            let url = try ImageStorage.saveDownscaledCover(image)
                            await MainActor.run {
                                viewModel.updateCover(url: url)
                                coverProcessingError = nil
                            }
                        } catch {
                            await MainActor.run {
                                coverProcessingError = "No se pudo guardar la portada. Inténtalo de nuevo."
                            }
                        }
                    }
                }
            }
            .alert("Error al procesar la portada", isPresented: Binding(
                get: { coverProcessingError != nil },
                set: { _ in coverProcessingError = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(coverProcessingError ?? "")
            }
        }
    }
}

// MARK: - Portada

extension AddEditBookView {
    private var coverSection: some View {
        Section {
            Button {
                // En el siguiente paso conectaremos esto con la cámara / selector de fotos.
                isShowingCoverScanner = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        .foregroundStyle(.secondary)
                        .frame(height: 180)

                    if let url = viewModel.coverURL {
                        KFImage(url)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                            Text("Añadir portada")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Idiomas soportados

private struct LanguageOption: Identifiable {
    let id: String   // mismo que code
    let code: String
    let displayName: String

    init(code: String, displayName: String) {
        self.id = code
        self.code = code
        self.displayName = displayName
    }
}

extension AddEditBookView {
    /// Lista de idiomas que mostramos en el picker.
    private var languageOptions: [LanguageOption] {
        let codes = ["es", "en", "fr", "de", "it"]
        var options = codes.compactMap { code -> LanguageOption? in
            let name = Locale.current.localizedString(forLanguageCode: code) ?? code
            return LanguageOption(code: code, displayName: name.capitalized)
        }

        // Si el libro tiene un código no incluido, lo añadimos como opción extra.
        if !viewModel.language.isEmpty,
           !options.contains(where: { $0.code == viewModel.language }) {
            let name = Locale.current.localizedString(forLanguageCode: viewModel.language)
                ?? viewModel.language
            options.append(LanguageOption(code: viewModel.language, displayName: name.capitalized))
        }

        return options
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

