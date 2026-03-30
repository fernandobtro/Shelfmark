//
//  Publisher.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Domain entity `Publisher`.
//

import Foundation

/// Domain entity `Publisher`.
struct Publisher: Equatable {
    let id: UUID
    let name: String
}
