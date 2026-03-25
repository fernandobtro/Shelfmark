//
//  LibraryStatsView.swift
//  Shelfmark
//

import SwiftUI
import Observation

struct LibraryStatsView: View {
    @Bindable var viewModel: LibraryStatsViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Calculando estadísticas…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .error(let message):
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let stats):
                ScrollView {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            StatCard(title: "Libros leídos", value: "\(stats.completedBooks)")
                            StatCard(title: "En progreso", value: "\(stats.inProgressBooks)")
                        }
                        HStack(spacing: 12) {
                            StatCard(title: "Páginas leídas", value: "\(stats.totalPagesRead)")
                            StatCard(title: "Total libros", value: "\(stats.totalBooks)")
                        }
                        HStack(spacing: 12) {
                            StatCard(title: "Por leer", value: "\(stats.pendingBooks)")
                            StatCard(
                                title: "Completado",
                                value: "\(Int((stats.completionRate * 100).rounded()))%"
                            )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progreso promedio")
                                .font(.headline)
                            ProgressView(value: stats.averageProgress, total: 1.0)
                            Text("\(Int((stats.averageProgress * 100).rounded()))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.theme.secondaryBackground)
                        )
                    }
                    .padding()
                }
            }
        }
        .background(Color.theme.mainBackground)
        .navigationTitle("Estadísticas")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.theme.secondaryBackground)
        )
    }
}

#Preview {
    struct PreviewFetchLibrary: FetchLibraryUseCaseProtocol {
        func execute() async throws -> [Book] { PreviewHelpers.previewBooks }
        func executePaginated(limit: Int, offset: Int) async throws -> [Book] {
            Array(PreviewHelpers.previewBooks.dropFirst(offset).prefix(limit))
        }
    }

    let vm = LibraryStatsViewModel(
        fetchLibraryUseCase: PreviewFetchLibrary(),
        calculateReadingStatsUseCase: CalculateReadingStatsUseCaseImpl.shared
    )
    return NavigationStack {
        LibraryStatsView(viewModel: vm)
    }
}
