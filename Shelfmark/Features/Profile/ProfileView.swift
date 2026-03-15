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

#Preview {
    NavigationStack {
        ProfileView(viewModel: ProfileViewModel(
            userProfileRepository: PreviewUserProfileRepository(),
            fetchLibraryUseCase: PreviewFetchLibraryForProfile(),
            fetchQuotesUseCase: PreviewFetchQuotesForProfile(),
            fetchReadingListsUseCase: PreviewFetchListsForProfile()
        ))
    }
}

private struct PreviewUserProfileRepository: UserProfileRepositoryProtocol {
    func getDisplayName() -> String { "" }
    func setDisplayName(_ name: String) {}
}

private struct PreviewFetchLibraryForProfile: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { [] }
}

private struct PreviewFetchQuotesForProfile: FetchQuotesUseCaseProtocol {
    func execute() async throws -> [Quote] { [] }
}

private struct PreviewFetchListsForProfile: FetchReadingListUseCaseProtocol {
    func execute() async throws -> [ReadingList] { [] }
}
