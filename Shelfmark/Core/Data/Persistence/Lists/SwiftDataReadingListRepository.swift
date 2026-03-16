//
//  SwiftDataReadingListRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation
import SwiftData

class SwiftDataReadingListRepository: ReadingListRepositoryProtocol {
    
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAllLists() async throws -> [ReadingList] {
        let descriptor = FetchDescriptor<ReadingListEntity>()
        let entities: [ReadingListEntity] = try modelContext.fetch(descriptor)
        return entities.map(ReadingListPersistenceMapper.toDomain)
    }

    func fetchListsPaginated(limit: Int, offset: Int) async throws -> [ReadingList] {
        var descriptor = FetchDescriptor<ReadingListEntity>()
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        let entities: [ReadingListEntity] = try modelContext.fetch(descriptor)
        return entities.map(ReadingListPersistenceMapper.toDomain)
    }

    func createList(name: String) async throws -> ReadingList {
        let entity = ReadingListEntity(
            id: UUID(),
            name: name,
            createdAt: Date()
        )
        modelContext.insert(entity)
        try modelContext.save()
        return ReadingListPersistenceMapper.toDomain(entity)
    }
    
    func renameList(id: UUID, name: String) async throws {
        let predicate = #Predicate<ReadingListEntity> { $0.id == id }
        let descriptor = FetchDescriptor<ReadingListEntity>(predicate: predicate)
        let lists = try modelContext.fetch(descriptor)
        guard let list = lists.first else { return }
        list.name = name
        try modelContext.save()
    }
    
    func deleteList(id: UUID) async throws {
        let predicate = #Predicate<ReadingListEntity> { $0.id == id }
        let descriptor = FetchDescriptor<ReadingListEntity>(predicate: predicate)
        let lists = try modelContext.fetch(descriptor)
        if let list = lists.first {
            modelContext.delete(list)
            try modelContext.save()
        }
    }
    
    func fetchBooks(inList id: UUID) async throws -> [Book] {
        let predicate = #Predicate<ReadingListEntity> { $0.id == id }
        let descriptor = FetchDescriptor<ReadingListEntity>(predicate: predicate)
        let lists = try modelContext.fetch(descriptor)
        guard let list = lists.first else { return [] }

        // Tomamos los BookEntity asociados a los items de la lista
        let books = list.items.compactMap { $0.book }
        return books.map(BookPersistenceMapper.toDomain)
    }
    
    func addBook(_ bookId: UUID, toList listId: UUID) async throws {
        // Buscar la lista
        let listPredicate = #Predicate<ReadingListEntity> { $0.id == listId }
        let listDescriptor = FetchDescriptor<ReadingListEntity>(predicate: listPredicate)
        guard let list = try modelContext.fetch(listDescriptor).first else { return }

        // Buscar el libro
        let bookPredicate = #Predicate<BookEntity> { $0.id == bookId }
        let bookDescriptor = FetchDescriptor<BookEntity>(predicate: bookPredicate)
        guard let book = try modelContext.fetch(bookDescriptor).first else { return }

        // Crear item y asociarlo
        let item = ReadingListItemEntity()
        item.listId = list
        item.book = book
        list.items.append(item)

        modelContext.insert(item)
        try modelContext.save()
    }
    
    func removeBook(_ bookId: UUID, fromList listID: UUID) async throws {
        let listPredicate = #Predicate<ReadingListEntity> { $0.id == listID }
        let listDescriptor = FetchDescriptor<ReadingListEntity>(predicate: listPredicate)
        guard let list = try modelContext.fetch(listDescriptor).first else { return }

        // Buscar el item correspondiente a ese libro dentro de la lista
        if let item = list.items.first(where: { $0.book?.id == bookId }) {
            modelContext.delete(item)
            try modelContext.save()
        }
    }
    
    func fetchList(byId id: UUID) async throws -> ReadingList? {
        let listPredicate = #Predicate<ReadingListEntity> { $0.id == id }
        let listDescriptor = FetchDescriptor<ReadingListEntity>(predicate: listPredicate)
        
        guard let entity = try modelContext.fetch(listDescriptor).first else {
            return nil
        }
        return ReadingListPersistenceMapper.toDomain(entity)
    }
}
