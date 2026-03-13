//
//  RootView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import SwiftUI

struct RootView: View {
    let container: AppDIContainer

    @State private var libraryViewModel: LibraryViewModel
    @State private var selectedTab: TabBar = .library
    @State private var showAddOptionsDialog = false
    @State private var isPresentingScanner = false
    @State private var isPresentingAddBook = false
    @State private var scannerViewModel: BookScannerViewModel?
    @State private var bookToAddFromScanner: Book?
    @State private var showNotFoundAlert = false

    init(container: AppDIContainer) {
        self.container = container
        _libraryViewModel = State(initialValue: container.makeLibraryViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .padding(.bottom, 80)

            CustomTabBar(
                selectedTab: $selectedTab,
                onPlusButtonTap: {
                    showAddOptionsDialog = true
                }
            )
        }
        .confirmationDialog("Añadir libro", isPresented: $showAddOptionsDialog, titleVisibility: .visible) {
            Button("Escanear código de barras") {
                scannerViewModel = container.makeBookScannerViewModel()
                isPresentingScanner = true
            }
            Button("Añadir manualmente") {
                bookToAddFromScanner = nil
                isPresentingAddBook = true
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Elige cómo quieres añadir el libro.")
        }
        .sheet(isPresented: $isPresentingScanner, onDismiss: {
            scannerViewModel = nil
        }) {
            if let vm = scannerViewModel {
                BookScannerView(viewModel: vm)
                    .onChange(of: vm.state) { _, newState in
                        switch newState {
                        case .found(let book):
                            isPresentingScanner = false
                            bookToAddFromScanner = book
                            isPresentingAddBook = true
                        case .notFound:
                            isPresentingScanner = false
                            showNotFoundAlert = true
                        case .error:
                            break
                        default:
                            break
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresentingAddBook, onDismiss: {
            bookToAddFromScanner = nil
            Task { await libraryViewModel.loadLibrary() }
        }) {
            if let book = bookToAddFromScanner {
                container.makeAddEditBookView(mode: .addWithInitialData(book))
            } else {
                container.makeAddBookView()
            }
        }
        .alert("Libro no encontrado", isPresented: $showNotFoundAlert) {
            Button("Añadir manualmente") {
                isPresentingAddBook = true
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("No se encontró el libro con ese ISBN. ¿Quieres añadirlo manualmente?")
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .library:
            NavigationStack {
                LibraryView(viewModel: libraryViewModel)
                    .navigationDestination(for: UUID.self) { bookId in
                        let viewModel = container.makeBookDetailViewModel(bookId: bookId)
                        BookDetailView(viewModel: viewModel, container: container)
                    }
            }

        case .lists:
            NavigationStack {
                Text("Listas")
                    .navigationTitle(TabBar.lists.title)
            }

        case .quotes:
            NavigationStack {
                Text("Citas")
                    .navigationTitle(TabBar.quotes.title)
            }

        case .profile:
            NavigationStack {
                Text("Perfil")
                    .navigationTitle(TabBar.profile.title)
            }
        }
    }
}

#Preview {
    RootView(container: AppDIContainer())
}
