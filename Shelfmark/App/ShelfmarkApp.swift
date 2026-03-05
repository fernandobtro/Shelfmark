//
//  ShelfmarkApp.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import SwiftUI
import SwiftData

@main
struct ShelfmarkApp: App {
    @State private var container = AppDIContainer()
    
    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .modelContainer(container.modelContainer)
        }
    }
}
