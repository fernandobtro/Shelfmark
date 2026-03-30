//
//  LibrarySortMenuView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Sheet menu for selecting Library sort/group preferences.
//

import Foundation
import SwiftUI
import Observation

/// Provides sort and grouping controls bound to `LibraryViewModel` preferences.
struct LibrarySortMenuView: View {
    @Bindable var viewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            optionCard {
                sectionHeader(title: "Ordenar por", icon: "arrow.up.arrow.down")
                ForEach(SortOption.allCases, id: \.self) { option in
                    menuItem(
                        title: option.displayName,
                        isSelected: viewModel.sortOption == option,
                        action: { viewModel.selectSort(option) }
                    )
                }
            }

            optionCard {
                sectionHeader(title: "Agrupar por", icon: "rectangle.3.group")
                ForEach(GroupOption.allCases, id: \.self) { option in
                    menuItem(
                        title: option.displayName,
                        isSelected: viewModel.groupOption == option,
                        action: { viewModel.selectGroup(option) }
                    )
                }
            }

            Spacer(minLength: 0)

            Button("Listo") { dismiss() }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .buttonStyle(.borderedProminent)
                .tint(.primaryGreen)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color.theme.mainBackground)
    }
}

extension LibrarySortMenuView {
    @ViewBuilder
    private func optionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.secondaryBackground.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
            Text(title)
                .font(.caption2.weight(.bold))
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func menuItem(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? .textPrimary : .primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primaryGreen)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.theme.primaryGreen.opacity(0.14))
                }
            }
            .padding(.horizontal, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    let mockFetch = PreviewSortMenuFetchUseCase()
    let mockDelete = PreviewSortMenuDeleteUseCase()
    let vm = LibraryViewModel(
        fetchLibraryUseCase: mockFetch,
        deleteBookUseCase: mockDelete,
        userProfileRepository: UserDefaultsUserProfileRepository()
    )
    return LibrarySortMenuView(viewModel: vm)
}

private struct PreviewSortMenuFetchUseCase: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] { [] }
}

private struct PreviewSortMenuDeleteUseCase: DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws {}
}

