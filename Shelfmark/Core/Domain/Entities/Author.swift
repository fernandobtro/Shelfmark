//
//  Author.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Domain entity `Author`.
//

import Foundation

/// Domain entity `Author`.
struct Author: Equatable {
    let id: UUID
    let name: String
}
