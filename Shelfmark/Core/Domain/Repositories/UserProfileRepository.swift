//
//  UserProfileRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import Foundation

protocol UserProfileRepositoryProtocol {
    func getDisplayName() -> String
    func setDisplayName(_ name: String)
}
