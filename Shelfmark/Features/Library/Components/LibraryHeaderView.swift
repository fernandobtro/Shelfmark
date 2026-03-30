//
//  LibraryHeaderView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Library header controls for filters and quick state toggles above the grid.
//

import Foundation
import SwiftUI
import Observation

/// Hosts top-level Library filtering controls and propagates selection changes.
struct LibraryHeaderView: View {
    @Bindable var viewModel: LibraryViewModel
    private let options: [FilterOption] = [.none, .reading, .read, .favorites, .pending]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    filterButton(option)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

private extension LibraryHeaderView {
    func filterButton(_ option: FilterOption) -> some View {
        let isSelected = viewModel.filterOption == option
        let title = option == .none ? "Todos" : option.displayName

        return Button(title) {
            // Tapping the same filter again toggles it off (equivalent to All).
            if isSelected {
                viewModel.selectFilter(.none)
            } else {
                viewModel.selectFilter(option)
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundColor(isSelected ? Color.white : Color.theme.textPrimary.opacity(0.8))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isSelected ? Color.theme.primaryGreen : Color.theme.secondaryBackground.opacity(0.7))
        )
        .overlay(
            Capsule()
                .stroke(Color.theme.textPrimary.opacity(isSelected ? 0.0 : 0.16), lineWidth: 1)
        )
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    let mockFetch = PreviewHeaderFetchUseCase()
    let mockDelete = PreviewHeaderDeleteUseCase()
    let vm = LibraryViewModel(
        fetchLibraryUseCase: mockFetch,
        deleteBookUseCase: mockDelete,
        userProfileRepository: UserDefaultsUserProfileRepository()
    )
    return LibraryHeaderView(viewModel: vm)
        .padding()
}

private struct PreviewHeaderFetchUseCase: FetchLibraryUseCaseProtocol {
    func execute() async throws -> [Book] { [] }
    func executePaginated(limit: Int, offset: Int) async throws -> [Book] { [] }
}

private struct PreviewHeaderDeleteUseCase: DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws {}
}

