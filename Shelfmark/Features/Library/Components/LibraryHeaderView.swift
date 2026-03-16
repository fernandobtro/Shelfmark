//
//  LibraryHeaderView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import SwiftUI
import Observation

struct LibraryHeaderView: View {
    @Bindable var viewModel: LibraryViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            filterButton(.all)
            filterButton(.reading)
            filterButton(.favorites)
        }
        .padding(.horizontal)
    }
}

private extension LibraryHeaderView {
    func filterButton(_ option: FilterOption) -> some View {
        let isSelected = viewModel.filterOption == option

        return Button(option.displayName) {
            viewModel.selectFilter(option)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundColor(isSelected ? Color.white : Color.secondary)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.theme.primaryGreen : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.theme.textPrimary.opacity(0.3), lineWidth: 1)
        )
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    let mockFetch = PreviewHeaderFetchUseCase()
    let mockDelete = PreviewHeaderDeleteUseCase()
    let vm = LibraryViewModel(fetchLibraryUseCase: mockFetch, deleteBookUseCase: mockDelete)
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

