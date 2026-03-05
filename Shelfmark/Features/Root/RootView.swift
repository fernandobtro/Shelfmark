//
//  RootView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import SwiftUI

struct RootView: View {
    
    let container: AppDIContainer
    @StateObject private var libraryViewModel: LibraryViewModel
    @State private var isPresentingAddBook = false
    
    init(container: AppDIContainer) {
        self.container = container
        _libraryViewModel = StateObject(wrappedValue: LibraryViewModel(fetchLibraryUseCase: container.fetchLibraryUseCase, deleteBookUseCase: container.deleteBookUseCase))
    }
    
    var body: some View {
        NavigationStack {
            LibraryView(viewModel: libraryViewModel)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isPresentingAddBook = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
        .sheet(isPresented: $isPresentingAddBook) {
            AddEditBookView(
                viewModel: AddEditBookViewModel(
                    mode: .add,
                    saveBookUseCase: container.saveBookUseCase
                )
            )
        }
    }
}

#Preview {
    RootView(container: AppDIContainer())
}
