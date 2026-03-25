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
    @State private var container: AppDIContainer?
    private let isRunningTests: Bool

    init() {
        let args = ProcessInfo.processInfo.arguments
        let isUITesting = args.contains("-ui-testing")
        let env = ProcessInfo.processInfo.environment
        let dyldHasXCTest = env["DYLD_INSERT_LIBRARIES"]?
            .localizedCaseInsensitiveContains("xctest") == true
        let runningTests = !isUITesting && (
            env["XCTestConfigurationFilePath"] != nil ||
            env["XCTestBundlePath"] != nil ||
            env["XCInjectBundle"] != nil ||
            env["XCInjectBundleInto"] != nil ||
            dyldHasXCTest ||
            NSClassFromString("XCTestCase") != nil
        )
        self.isRunningTests = runningTests
        _container = State(
            initialValue: runningTests ? nil : AppDIContainer(useInMemoryStore: isUITesting)
        )
    }
    
    var body: some Scene {
        WindowGroup {
            if isRunningTests {
                EmptyView()
            } else if let container {
                RootView(container: container)
                    .modelContainer(container.modelContainer)
            }
        }
    }
}
