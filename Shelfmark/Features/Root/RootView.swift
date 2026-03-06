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
    @State private var selectedTab: TabBar = .library
    @State private var isPresentingAddBook = false

    init(container: AppDIContainer) {
        self.container = container
        _libraryViewModel = StateObject(
            wrappedValue: container.makeLibraryViewModel()
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            tabContent
                .padding(.bottom, 80)
            
            CustomTabBar(
                selectedTab: $selectedTab,
                onPlusButtonTap: {
                    isPresentingAddBook = true
                }
            )
        }
        .sheet(isPresented: $isPresentingAddBook) {
            container.makeAddBookView()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        
        switch selectedTab {
            
        case .library:
            
            NavigationStack {
                LibraryView(viewModel: libraryViewModel)
                    .navigationDestination(for: UUID.self) { bookId in
                        
                        let viewModel = container.makeBookDetailViewModel(
                            bookId: bookId
                        )
                        
                        BookDetailView(
                            viewModel: viewModel,
                            container: container
                        )
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
