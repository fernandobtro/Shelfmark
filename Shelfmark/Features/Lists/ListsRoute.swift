//
//  ListsRoute.swift
//  Shelfmark
//
//  Purpose: Navigation route definitions for Lists flows (list detail and linked book detail).
//

import Foundation

/// Encapsulates strongly typed navigation targets used by the Lists tab.
enum ListsRoute: Hashable {
    case list(UUID)
    case book(UUID)
}
