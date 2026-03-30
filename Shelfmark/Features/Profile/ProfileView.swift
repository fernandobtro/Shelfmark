//
//  ProfileView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//
//  Purpose: Profile tab screen for display-name preferences and account-level reading counters.
//

import SwiftUI

/// Shows profile preferences and summary metrics sourced from `ProfileViewModel`.
struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @State private var retryTrigger = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                nameSection
                statsSection
                settingsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTapOutside()
        .background(Color.theme.mainBackground)
        .navigationTitle("Perfil")
        .task(id: retryTrigger) {
            await viewModel.load()
        }
        .onDisappear { viewModel.saveDisplayName(viewModel.displayName) }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tu nombre")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            card {
                TextField("¿Cómo te llamas?", text: $viewModel.displayName)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                    .onSubmit { viewModel.saveDisplayName(viewModel.displayName) }
                    .onChange(of: viewModel.displayName) { _, newValue in
                        viewModel.saveDisplayName(newValue)
                    }
            }
        }
    }

    @ViewBuilder
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estadísticas")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            switch viewModel.state {
            case .idle, .loading:
                card {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

            case .loaded(let booksCount, let quotesCount, let listsCount):
                card {
                    VStack(spacing: 10) {
                        StatRow(title: "Libros en biblioteca", value: booksCount)
                        Divider()
                        StatRow(title: "Citas guardadas", value: quotesCount)
                        Divider()
                        StatRow(title: "Listas creadas", value: listsCount)
                    }
                }

            case .error(let message):
                card {
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
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Configuración")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            card {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Label("Tamaño de grid en Biblioteca", systemImage: "square.grid.2x2")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Picker(
                        "Tamaño de grid",
                        selection: Binding(
                            get: { viewModel.libraryGridLayoutOption },
                            set: { viewModel.setLibraryGridLayoutOption($0) }
                        )
                    ) {
                        ForEach(LibraryGridLayoutOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
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
}

private struct StatRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Vacío") {
    NavigationStack {
        ProfileView(viewModel: ProfileViewModel(
            userProfileRepository: PreviewUserProfileRepository(),
            fetchLibraryUseCase: PreviewFetchLibraryForProfile(),
            fetchQuotesUseCase: PreviewFetchQuotesForProfile(),
            fetchReadingListsUseCase: PreviewFetchListsForProfile()
        ))
    }
}

#Preview("Con estadísticas") {
    let vm = ProfileViewModel(
        userProfileRepository: PreviewUserProfileRepositoryWithName(),
        fetchLibraryUseCase: PreviewProfileFetchLibraryWithData(),
        fetchQuotesUseCase: PreviewProfileFetchQuotesWithData(),
        fetchReadingListsUseCase: PreviewProfileFetchListsWithData()
    )
    return NavigationStack {
        ProfileView(viewModel: vm)
            .task { await vm.load() }
    }
}

private struct PreviewUserProfileRepository: UserProfileRepositoryProtocol {
    func getDisplayName() -> String { "" }
    func setDisplayName(_ name: String) {}
    func getLibraryGridLayoutOption() -> LibraryGridLayoutOption { .standard }
    func setLibraryGridLayoutOption(_ option: LibraryGridLayoutOption) {}
}

private struct PreviewUserProfileRepositoryWithName: UserProfileRepositoryProtocol {
    func getDisplayName() -> String { "Fernando" }
    func setDisplayName(_ name: String) {}
    func getLibraryGridLayoutOption() -> LibraryGridLayoutOption { .standard }
    func setLibraryGridLayoutOption(_ option: LibraryGridLayoutOption) {}
}

private struct PreviewFetchLibraryForProfile: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] { [] }
}

private struct PreviewProfileFetchLibraryWithData: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { PreviewHelpers.previewBooks }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] {
        Array(PreviewHelpers.previewBooks.dropFirst(offset).prefix(limit))
    }
}

private struct PreviewFetchQuotesForProfile: FetchQuotesUseCaseProtocol {
    func execute() async throws -> [Quote] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [Quote] { [] }
}

private struct PreviewProfileFetchQuotesWithData: FetchQuotesUseCaseProtocol {
    let quotes = [PreviewHelpers.previewQuote(bookId: PreviewHelpers.previewBook1.id)]
    func execute() async throws -> [Quote] { quotes }
    func executePaginated(limit: Int, offset: Int) async throws -> [Quote] {
        Array(quotes.dropFirst(offset).prefix(limit))
    }
}

private struct PreviewFetchListsForProfile: FetchReadingListUseCaseProtocol {
    func execute() async throws -> [ReadingList] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList] { [] }
}

private struct PreviewProfileFetchListsWithData: FetchReadingListUseCaseProtocol {
    let lists = [PreviewHelpers.previewReadingList]
    func execute() async throws -> [ReadingList] { lists }
    func executePaginated(limit: Int, offset: Int) async throws -> [ReadingList] {
        Array(lists.dropFirst(offset).prefix(limit))
    }
}
