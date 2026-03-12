//
//  NavigationRouter.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import SwiftUI
import Observation

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

