//
//  UserDefaultsUserProfileRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import Foundation

private enum UserProfileKeys {
    static let displayName = "profileUserDisplayName"
}

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
}
