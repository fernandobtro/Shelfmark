//
//  UserDefaultsUserProfileRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//
//  Purpose: User profile repository persisted in `UserDefaults` for lightweight preferences.
//

import Foundation

private enum UserProfileKeys {
    static let displayName = "profileUserDisplayName"
    static let libraryGridLayoutOption = "libraryGridLayoutOption"
}

/// Stores and reads profile-level preferences such as display name and layout options.
final class UserDefaultsUserProfileRepository: UserProfileRepositoryProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getDisplayName() -> String {
        userDefaults.string(forKey: UserProfileKeys.displayName) ?? ""
    }

    func setDisplayName(_ name: String) {
        userDefaults.set(name, forKey: UserProfileKeys.displayName)
    }

    func getLibraryGridLayoutOption() -> LibraryGridLayoutOption {
        guard
            let rawValue = userDefaults.string(forKey: UserProfileKeys.libraryGridLayoutOption),
            let option = LibraryGridLayoutOption(rawValue: rawValue)
        else {
            return .standard
        }
        return option
    }

    func setLibraryGridLayoutOption(_ option: LibraryGridLayoutOption) {
        userDefaults.set(option.rawValue, forKey: UserProfileKeys.libraryGridLayoutOption)
    }
}
