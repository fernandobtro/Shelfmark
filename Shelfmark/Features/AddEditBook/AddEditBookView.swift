//
//  AddEditBookView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Book form screen used for create/edit flows, scanner-prefilled entries, and cover capture handoff.
//

import SwiftUI
import Observation
import Kingfisher

/// Collects book metadata and delegates validation/persistence to `AddEditBookViewModel`.
struct AddEditBookView: View {
    @Bindable var viewModel: AddEditBookViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var saveTrigger = 0
    @State private var isShowingCoverScanner = false
    @State private var coverProcessingError: String?

    private var isInteractionLocked: Bool {
        viewModel.isSaving
    }

    var body: some View {
        NavigationStack {
            Form {
                formSections
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTapOutside()
            .background(Color.theme.mainBackground)
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(isInteractionLocked)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveTrigger += 1
                    } label: {
                        if viewModel.isSaving {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Guardando…")
                            }
                        } else {
                            Text("Guardar")
                        }
                    }
                    .accessibilityIdentifier("book.form.save")
                    .disabled(viewModel.isSaving)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if viewModel.isSaving {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Guardando libro…")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.theme.secondaryBackground.opacity(0.92))
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.bottom, 10)
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
    @ViewBuilder
    private var formSections: some View {
        coverSection
        bookInfoSection
        authorsSection
        detailsSection
        descriptionSection
        statusSection
        progressSection
        if let error = viewModel.errorMessage {
            errorSection(error)
        }
    }

    private var bookInfoSection: some View {
        Section("Información del libro") {
            fieldCard {
                VStack(spacing: 10) {
                    TextField("Título", text: $viewModel.title)
                        .accessibilityIdentifier("book.form.title")
                    Divider()
                    TextField("Subtítulo", text: $viewModel.subtitle)
                }
            }
            .styledFormRow()
        }
    }

    private var authorsSection: some View {
        Section("Autores") {
            fieldCard {
                TextField("Autor(es), separados por comas", text: $viewModel.authorsText)
            }
            .styledFormRow()
        }
    }

    private var detailsSection: some View {
        Section("Detalles") {
            fieldCard {
                VStack(spacing: 10) {
                    TextField("ISBN", text: $viewModel.isbn)
                    Divider()
                    TextField("Editorial", text: $viewModel.publisherName)
                    Divider()
                    TextField("Número de páginas", text: $viewModel.pagesText)
                        .keyboardType(.numberPad)
                    Divider()
                    DatePicker(
                        "Fecha de publicación",
                        selection: Binding(
                            get: { viewModel.publicationDate ?? Date() },
                            set: { viewModel.publicationDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .opacity(viewModel.publicationDate == nil ? 0.6 : 1)
                    Divider()
                    Picker("Idioma", selection: $viewModel.language) {
                        ForEach(languageOptions) { option in
                            Text(option.displayName).tag(option.code)
                        }
                    }
                }
            }
            .styledFormRow()
        }
    }

    private var descriptionSection: some View {
        Section("Descripción") {
            fieldCard {
                TextField("Descripción", text: $viewModel.descriptionText, axis: .vertical)
                    .lineLimit(3...6)
            }
            .styledFormRow()
        }
    }

    private var statusSection: some View {
        Section("Estado") {
            fieldCard {
                VStack(spacing: 10) {
                    Toggle("Favorito", isOn: $viewModel.isFavorite)
                    Divider()
                    Picker("Estado", selection: $viewModel.readingStatus) {
                        ForEach(ReadingStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }
            }
            .styledFormRow()
        }
    }

    private var progressSection: some View {
        Section("Progreso de lectura") {
            fieldCard {
                TextField("Página actual (opcional)", text: $viewModel.currentPageText)
                    .keyboardType(.numberPad)
            }
            .styledFormRow()
        }
    }

    private func errorSection(_ message: String) -> some View {
        Section {
            fieldCard {
                Text(message)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.red.opacity(0.28), lineWidth: 1)
            )
            .styledFormRow()
        }
    }

    @ViewBuilder
    private func fieldCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 12)
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

    private var coverSection: some View {
        Section {
            Button {
                // This hook can be connected to camera/photo picker flow.
                isShowingCoverScanner = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.theme.secondaryBackground.opacity(0.72))
                        .frame(height: 180)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .overlay {
                            if viewModel.coverURL == nil {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                    .foregroundStyle(.secondary.opacity(0.6))
                            }
                        }

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
            .styledFormRow()
        }
    }
}

private extension View {
    func styledFormRow() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
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
    /// Language options shown by the picker.
    private var languageOptions: [LanguageOption] {
        let codes = ["es", "en", "fr", "de", "it"]
        var options = codes.compactMap { code -> LanguageOption? in
            let name = Locale.current.localizedString(forLanguageCode: code) ?? code
            return LanguageOption(code: code, displayName: name.capitalized)
        }

        // If the current book language code is missing, append it as an extra.
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

