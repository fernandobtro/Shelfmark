//
//  UserProfileRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//
//  Purpose: Repository boundary `UserProfileRepository`.
//

import Foundation

/// Repository boundary `UserProfileRepository`.
protocol UserProfileRepositoryProtocol {
    func getDisplayName() -> String
    func setDisplayName(_ name: String)
    func getLibraryGridLayoutOption() -> LibraryGridLayoutOption
    func setLibraryGridLayoutOption(_ option: LibraryGridLayoutOption)
}
