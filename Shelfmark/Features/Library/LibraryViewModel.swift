//
//  LibraryViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation
import Observation

enum LibraryState: Equatable {
    case idle
    case loading
    case loaded([Book])
    case error(String)
}

@Observable
final class LibraryViewModel {
    var state: LibraryState = .idle
    var sortOption: SortOption = .title
    var groupOption: GroupOption = .none
    var isShowingSortMenu: Bool = false
    /// Filtro actual. `.none` significa "mostrar todos los libros".
    var filterOption: FilterOption = .none
    var searchText: String = ""
    
    let pageSize = 20
    var currentOffset = 0
    var hasMore = true
    var isLoadingNextPage = false

    var sectionedBooks: [LibrarySection] {
        guard case .loaded(let books) = state else { return [] }

        let searchFiltered = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let booksAfterSearch = searchFiltered.isEmpty ? books : books.filter { book in
            let query = searchFiltered.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current)
            let titleMatch = book.title.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(query)
            let authorMatch = book.authors.contains { author in
                author.name.localizedLowercase.folding(options: .diacriticInsensitive, locale: .current).contains(query)
            }
            return titleMatch || authorMatch
        }

        let filteredBooks = booksAfterSearch.filter { book in
            switch filterOption {
            case .none:
                return true
            case .read:
                return book.readingStatus == .read
            case .reading:
                return book.readingStatus == .reading
            case .favorites:
                return book.isFavorite
            case .pending:
                return book.readingStatus == .pending
            }
        }
        
        let sortedBooks = filteredBooks.sorted { book1, book2 in
            switch sortOption {
            case .title:
                return book1.title.localizedCaseInsensitiveCompare(book2.title) == .orderedAscending
            case .author:
                let author1 = book1.authors.first?.name ?? ""
                let author2 = book2.authors.first?.name ?? ""
                return author1.localizedCaseInsensitiveCompare(author2) == .orderedAscending
            }
        }

        switch groupOption {
        case .publisher:
            let grouped = Dictionary(grouping: sortedBooks) { book in
                book.publisher?.name ?? "Editorial desconocida"
            }
            return makeSections(from: grouped)
        case .author:
            let grouped = Dictionary(grouping: sortedBooks) { book in
                book.authors.first?.name ?? "Autor desconocido"
            }
            return makeSections(from: grouped)
        case .none:
            return [LibrarySection(categoryName: "Todos", books: sortedBooks)]
        }
    }

    private let fetchLibraryUseCase: FetchLibraryUseCaseProtocol
    private let deleteBookUseCase: DeleteBookUseCaseProtocol

    init(fetchLibraryUseCase: FetchLibraryUseCaseProtocol, deleteBookUseCase: DeleteBookUseCaseProtocol) {
        self.fetchLibraryUseCase = fetchLibraryUseCase
        self.deleteBookUseCase = deleteBookUseCase
    }

    /// Libera los datos en memoria cuando el usuario sale de la pestaña Biblioteca.
    func unload() {
        state = .idle
        currentOffset = 0
        hasMore = true
    }

    func loadLibrary() async {
        state = .loading
        currentOffset = 0
        hasMore = true
        
        do {
            let books = try await fetchLibraryUseCase.executePaginated(limit: pageSize, offset: 0)
            await MainActor.run {
                state = .loaded(books)
                currentOffset = books.count
                if books.count < pageSize {
                    hasMore = false
                }
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func loadNextPage() async {
        guard !isLoadingNextPage, hasMore else { return }
        
        guard case .loaded(let existing) = state else { return }
        
        isLoadingNextPage = true
        
        defer { isLoadingNextPage = false }
        
        do {
            let newPage = try await fetchLibraryUseCase.executePaginated(
                limit: pageSize,
                offset: currentOffset
            )
            await MainActor.run {
                state = .loaded(existing + newPage)
                
                currentOffset += newPage.count
                
                if newPage.count < pageSize {
                    hasMore = false
                }
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func delete(bookId: UUID) async {
        do {
            try await deleteBookUseCase.execute(bookId: bookId)
            await loadLibrary()
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }

    func selectSort(_ option: SortOption) {
        sortOption = option
    }

    func selectGroup(_ option: GroupOption) {
        groupOption = option
    }

    func selectFilter(_ option: FilterOption) {
        filterOption = option
    }

    // MARK: - Helper
    private func makeSections(from dictionary: [String: [Book]]) -> [LibrarySection] {
        dictionary
            .map { key, value in
                LibrarySection(categoryName: key, books: value)
            }
            .sorted {
                $0.categoryName.localizedCaseInsensitiveCompare($1.categoryName) == .orderedAscending
            }
    }
}

