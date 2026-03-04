//
//  Publisher.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

struct Publisher {
    let id: UUID
    let name: String
    let books: [Book]
    let authors: [Author]
}
