//
//  NavigationRouter.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Application wiring component `NavigationRouter`.
//

import SwiftUI
import Observation

/// Application wiring component `NavigationRouter`.
@Observable
class NavigationRouter {
    var path = NavigationPath()

    func navigate(to destination: AnyHashable) {
        path.append(destination)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}

