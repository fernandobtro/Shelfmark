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
    @State private var profileViewModel: ProfileViewModel
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
    @State private var refreshLibraryTrigger = 0
    @State private var refreshQuotesTrigger = 0

    init(container: AppDIContainer) {
        self.container = container
        _libraryViewModel = State(initialValue: container.makeLibraryViewModel())
        _listsViewModel = State(initialValue: container.makeListsViewModel())
        _quotesViewModel = State(initialValue: container.makeQuotesViewModel())
        _profileViewModel = State(initialValue: container.makeProfileViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.theme.mainBackground
                .ignoresSafeArea()

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
        .onChange(of: selectedTab) { oldTab, newTab in
            guard oldTab != newTab else { return }
            switch oldTab {
            case .library: libraryViewModel.unload()
            case .quotes: quotesViewModel.unload()
            case .lists: listsViewModel.unload()
            case .profile: profileViewModel.unload()
            }
        }
        .sheet(isPresented: $showAddOptionsDialog) {
            AddBookOptionsSheetView(
                onScanISBN: {
                    scannerViewModel = container.makeBookScannerViewModel()
                    isPresentingScanner = true
                },
                onAddManually: {
                    bookToAddFromScanner = nil
                    isPresentingAddBook = true
                },
                onDismiss: {
                    showAddOptionsDialog = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
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
            refreshLibraryTrigger += 1
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
            refreshQuotesTrigger += 1
        }) {
            if let vm = quoteScannerViewModel {
                QuoteScannerView(viewModel: vm, container: container)
            }
        }
        .sheet(isPresented: $showAddEditQuoteSheet, onDismiss: {
            refreshQuotesTrigger += 1
        }) {
            AddEditQuoteView(
                viewModel: container.makeAddEditQuoteViewModel(mode: AddEditQuoteMode.add),
                onDelete: nil
            )
        }
        .task(id: refreshLibraryTrigger) {
            if refreshLibraryTrigger > 0 {
                await libraryViewModel.loadLibrary()
            }
        }
        .task(id: refreshQuotesTrigger) {
            if refreshQuotesTrigger > 0 {
                await quotesViewModel.loadQuotes()
            }
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
                ProfileView(viewModel: profileViewModel)
            }
        }
    }
}

#Preview {
    RootView(container: AppDIContainer())
}
