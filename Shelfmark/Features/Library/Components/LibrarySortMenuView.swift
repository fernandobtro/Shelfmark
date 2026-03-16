//
//  LibrarySortMenuView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import SwiftUI
import Observation

struct LibrarySortMenuView: View {
    @Bindable var viewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Ordenar por", icon: "arrow.up.arrow.down")
            ForEach(SortOption.allCases, id: \.self) { option in
                menuItem(
                    title: option.displayName,
                    isSelected: viewModel.sortOption == option,
                    action: { viewModel.selectSort(option) }
                )
            }

            sectionHeader(title: "Agrupar por", icon: "rectangle.3.group")
            ForEach(GroupOption.allCases, id: \.self) { option in
                menuItem(
                    title: option.displayName,
                    isSelected: viewModel.groupOption == option,
                    action: { viewModel.selectGroup(option) }
                )
            }

            Spacer(minLength: 24)
            Button("Listo") { dismiss() }
                .frame(maxWidth: .infinity)
                .padding()
        }
        .padding(.top, 8)
    }
}

extension LibrarySortMenuView {
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
            .background(isSelected ? Color.theme.primaryGreen.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    let mockFetch = PreviewSortMenuFetchUseCase()
    let mockDelete = PreviewSortMenuDeleteUseCase()
    let vm = LibraryViewModel(fetchLibraryUseCase: mockFetch, deleteBookUseCase: mockDelete)
    return LibrarySortMenuView(viewModel: vm)
}

private struct PreviewSortMenuFetchUseCase: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] { [] }
}

private struct PreviewSortMenuDeleteUseCase: DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws {}
}

