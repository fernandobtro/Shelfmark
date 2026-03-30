//
//  RootView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Root tab shell that composes feature tabs, global sheets, and cross-feature refresh triggers.
//

import SwiftUI

/// Hosts app-level tab navigation, modal flows, and dependency-wired feature entry points.
struct RootView: View {
    let container: AppDIContainer
    private let tabBarBottomPadding: CGFloat = 8
    private let tabBarContentInset: CGFloat = 84

    @State private var libraryViewModel: LibraryViewModel
    @State private var listsViewModel: ListsViewModel
    @State private var quotesViewModel: QuotesViewModel
    @State private var profileViewModel: ProfileViewModel
    @State private var selectedTab: TabBar = .library
    @State private var showAddOptionsDialog = false
    @State private var isPresentingScanner = false
    @State private var isPresentingAddBook = false
    @State private var showCreateListSheet = false
    @State private var quotesNavigationPath: [QuotesRoute] = []
    @State private var showQuoteAddOptionsDialog = false
    @State private var isPresentingQuoteTextScanner = false
    @State private var quoteTextScannerViewModel: QuoteTextScannerViewModel?
    @State private var pendingQuoteInitialText: String?
    @State private var shouldOpenManualQuoteAfterScannerDismiss = false
    @State private var scannerViewModel: BookScannerViewModel?
    @State private var bookToAddFromScanner: Book?
    @State private var showNotFoundAlert = false
    @State private var refreshLibraryTrigger = 0
    @State private var showLibraryStats = false

    init(container: AppDIContainer) {
        self.container = container
        _libraryViewModel = State(initialValue: container.makeLibraryViewModel())
        _listsViewModel = State(initialValue: container.makeListsViewModel())
        _quotesViewModel = State(initialValue: container.makeQuotesViewModel())
        _profileViewModel = State(initialValue: container.makeProfileViewModel())
    }

    var body: some View {
        ZStack {
            Color.theme.mainBackground
                .ignoresSafeArea()

            tabContent
                .padding(.bottom, tabBarContentInset)
        }
        .overlay(alignment: .bottom) {
            CustomTabBar(
                selectedTab: $selectedTab,
                onPlusButtonTap: {
                    switch selectedTab {
                    case .library:
                        showAddOptionsDialog = true
                    case .lists:
                        showCreateListSheet = true
                    case .quotes:
                        showQuoteAddOptionsDialog = true
                    case .profile:
                        break
                    }
                }
            )
            .padding(.bottom, tabBarBottomPadding)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: selectedTab) { oldTab, newTab in
            guard oldTab != newTab else { return }
            switch oldTab {
            case .library: libraryViewModel.unload()
            case .quotes: quotesViewModel.unload()
            case .lists: listsViewModel.unload()
            case .profile: profileViewModel.unload()
            }
            if newTab == .library {
                libraryViewModel.refreshDisplayPreferences()
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
        .sheet(isPresented: $isPresentingQuoteTextScanner, onDismiss: {
            quoteTextScannerViewModel = nil
            if let initialText = pendingQuoteInitialText {
                pendingQuoteInitialText = nil
                quotesNavigationPath.append(.addQuoteWithText(initialText))
            } else if shouldOpenManualQuoteAfterScannerDismiss {
                shouldOpenManualQuoteAfterScannerDismiss = false
                quotesNavigationPath.append(.addQuote)
            }
        }) {
            if let vm = quoteTextScannerViewModel {
                QuoteTextScannerView(
                    viewModel: vm,
                    onTextCaptured: { capturedText in
                        pendingQuoteInitialText = capturedText
                        isPresentingQuoteTextScanner = false
                    },
                    onFallbackToManual: {
                        shouldOpenManualQuoteAfterScannerDismiss = true
                        isPresentingQuoteTextScanner = false
                    },
                    onClose: {
                        shouldOpenManualQuoteAfterScannerDismiss = false
                        isPresentingQuoteTextScanner = false
                    }
                )
            }
        }
        .confirmationDialog("Añadir cita", isPresented: $showQuoteAddOptionsDialog, titleVisibility: .visible) {
            Button("Escanear texto") {
                quoteTextScannerViewModel = container.makeQuoteTextScannerViewModel()
                isPresentingQuoteTextScanner = true
            }
            .accessibilityIdentifier("quotes.addOption.scanText")
            Button("Escribir manualmente") {
                quotesNavigationPath.append(.addQuote)
            }
            .accessibilityIdentifier("quotes.addOption.manual")
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Elige cómo quieres crear tu cita.")
        }
        .task(id: refreshLibraryTrigger) {
            if refreshLibraryTrigger > 0 {
                await libraryViewModel.loadLibrary()
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .library:
            NavigationStack {
                LibraryView(
                    viewModel: libraryViewModel,
                    onStatsTap: { showLibraryStats = true }
                )
                    .navigationDestination(for: UUID.self) { bookId in
                        let viewModel = container.makeBookDetailViewModel(bookId: bookId)
                        BookDetailView(viewModel: viewModel, container: container)
                    }
                    .navigationDestination(isPresented: $showLibraryStats) {
                        LibraryStatsView(viewModel: container.makeLibraryStatsViewModel())
                    }
            }

        case .lists:
            NavigationStack {
                ListsView(viewModel: listsViewModel)
                    .navigationDestination(for: ListsRoute.self) { route in
                        switch route {
                        case .list(let listId):
                            ReadingListDetailView(
                                viewModel: container.makeReadingListDetailViewModel(listId: listId),
                                container: container
                            )
                        case .book(let bookId):
                            BookDetailView(
                                viewModel: container.makeBookDetailViewModel(bookId: bookId),
                                container: container
                            )
                        }
                    }
            }

        case .quotes:
            NavigationStack(path: $quotesNavigationPath) {
                QuotesView(viewModel: quotesViewModel, container: container)
                .navigationDestination(for: QuotesRoute.self) { route in
                    switch route {
                    case .addQuote:
                        AddEditQuoteView(
                            viewModel: container.makeAddEditQuoteViewModel(mode: .add),
                            onDelete: nil
                        )
                    case .addQuoteWithText(let text):
                        AddEditQuoteView(
                            viewModel: container.makeAddEditQuoteViewModel(mode: .addWithInitialText(text)),
                            onDelete: nil
                        )
                    case .editQuote(let quoteId):
                        AddEditQuoteView(
                            viewModel: container.makeAddEditQuoteViewModel(mode: .edit(quoteId: quoteId)),
                            onDelete: nil
                        )
                    case .quoteDetail(let quoteId):
                        QuoteDetailView(
                            viewModel: container.makeQuoteDetailViewModel(quoteId: quoteId),
                            container: container
                        )
                    case .bookQuotes(let bookId):
                        BookQuotesListView(bookId: bookId, viewModel: quotesViewModel, container: container)
                    case .authorQuotes(let authorName):
                        AuthorQuotesListView(authorName: authorName, viewModel: quotesViewModel, container: container)
                    case .bookDetail(let bookId):
                        BookDetailView(
                            viewModel: container.makeBookDetailViewModel(bookId: bookId),
                            container: container
                        )
                    }
                }
            }
            .onChange(of: quotesNavigationPath.count) { old, new in
                guard new < old else { return }
                Task { await quotesViewModel.loadQuotes() }
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
