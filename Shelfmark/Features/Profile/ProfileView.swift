//
//  ProfileView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        List {
            nameSection
            statsSection
            settingsSection
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTapOutside()
        .navigationTitle("Perfil")
        .task { await viewModel.load() }
        .onDisappear { viewModel.saveDisplayName(viewModel.displayName) }
    }

    private var nameSection: some View {
        Section {
            TextField("Cómo te llamas?", text: $viewModel.displayName)
                .textContentType(.name)
                .autocorrectionDisabled()
                .onSubmit { viewModel.saveDisplayName(viewModel.displayName) }
        } header: {
            Text("Tu nombre")
        }
    }

    @ViewBuilder
    private var statsSection: some View {
        Section {
            switch viewModel.state {
            case .idle, .loading:
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

            case .loaded(let booksCount, let quotesCount, let listsCount):
                StatRow(title: "Libros en biblioteca", value: booksCount)
                StatRow(title: "Citas guardadas", value: quotesCount)
                StatRow(title: "Listas creadas", value: listsCount)

            case .error(let message):
                Text(message)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Estadísticas")
        }
    }

    private var settingsSection: some View {
        Section {
            Label("Ajustes", systemImage: "gearshape")
                .foregroundStyle(.secondary)
            // Placeholder: en el futuro enlace a tema, notificaciones, etc.
        } header: {
            Text("Configuración")
        }
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
}

private struct PreviewUserProfileRepositoryWithName: UserProfileRepositoryProtocol {
    func getDisplayName() -> String { "Fernando" }
    func setDisplayName(_ name: String) {}
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
