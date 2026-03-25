//
//  ReadingStats.swift
//  Shelfmark
//

import Foundation

struct ReadingStats: Equatable {
    let totalBooks: Int
    let completedBooks: Int
    let inProgressBooks: Int
    let pendingBooks: Int
    let totalPagesRead: Int
    let averageProgress: Double
    let completionRate: Double
}
