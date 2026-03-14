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
    @State private var listsViewModel: ListsViewModel
    @State private var quotesViewModel: QuotesViewModel
    @State private var selectedTab: TabBar = .library
    @State private var showAddOptionsDialog = false
    @State private var isPresentingScanner = false
    @State private var isPresentingAddBook = false
    @State private var showCreateListSheet = false
    @State private var showAddQuoteOptionsDialog = false
    @State private var showScanQuoteSheet = false
    @State private var showAddEditQuoteSheet = false
    @State private var quoteScannerViewModel: QuoteScannerViewModel?
    @State private var scannerViewModel: BookScannerViewModel?
    @State private var bookToAddFromScanner: Book?
    @State private var showNotFoundAlert = false

    init(container: AppDIContainer) {
        self.container = container
        _libraryViewModel = State(initialValue: container.makeLibraryViewModel())
        _listsViewModel = State(initialValue: container.makeListsViewModel())
        _quotesViewModel = State(initialValue: container.makeQuotesViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .padding(.bottom, 80)

            CustomTabBar(
                selectedTab: $selectedTab,
                onPlusButtonTap: {
                    switch selectedTab {
                    case .library:
                        showAddOptionsDialog = true
                    case .lists:
                        showCreateListSheet = true
                    case .quotes:
                        showAddQuoteOptionsDialog = true
                    case .profile:
                        break
                    }
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
        .sheet(isPresented: $showCreateListSheet) {
            CreateListSheetView(
                viewModel: listsViewModel,
                onDismiss: { showCreateListSheet = false }
            )
        }
        .confirmationDialog("Añadir cita", isPresented: $showAddQuoteOptionsDialog, titleVisibility: .visible) {
            Button("Escanear cita") {
                quoteScannerViewModel = container.makeQuoteScannerViewModel()
                showScanQuoteSheet = true
            }
            Button("Añadir manualmente") {
                showAddEditQuoteSheet = true
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Usa la cámara para escanear texto o añade la cita a mano.")
        }
        .sheet(isPresented: $showScanQuoteSheet, onDismiss: {
            quoteScannerViewModel = nil
            Task { await quotesViewModel.loadQuotes() }
        }) {
            if let vm = quoteScannerViewModel {
                QuoteScannerView(viewModel: vm, container: container)
            }
        }
        .sheet(isPresented: $showAddEditQuoteSheet, onDismiss: {
            Task { await quotesViewModel.loadQuotes() }
        }) {
            AddEditQuoteView(
                viewModel: container.makeAddEditQuoteViewModel(mode: AddEditQuoteMode.add),
                onDelete: nil
            )
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
                ListsView(viewModel: listsViewModel)
                    .navigationDestination(for: UUID.self) { listId in
                        ReadingListDetailView(viewModel: container.makeReadingListDetailViewModel(listId: listId), container: container)
                    }
            }

        case .quotes:
            NavigationStack {
                QuotesView(viewModel: quotesViewModel, container: container)
                    .navigationDestination(for: UUID.self) { quoteId in
                        QuoteDetailView(
                            viewModel: container.makeQuoteDetailViewModel(quoteId: quoteId),
                            container: container
                        )
                    }
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
