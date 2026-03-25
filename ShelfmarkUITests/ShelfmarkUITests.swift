//
//  ShelfmarkUITests.swift
//  ShelfmarkUITests
//

import XCTest

final class ShelfmarkUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()
    }

    func test_smoke_launchAndTabNavigation() throws {
        XCTAssertTrue(app.navigationBars["Mi Biblioteca"].waitForExistence(timeout: 5))

        app.buttons["tabbar.listas"].tap()
        XCTAssertTrue(app.navigationBars["Listas"].waitForExistence(timeout: 5))

        app.buttons["tabbar.citas"].tap()
        XCTAssertTrue(app.navigationBars["Citas"].waitForExistence(timeout: 5))
    }

    func test_smoke_createListFromPlusButton() throws {
        app.buttons["tabbar.listas"].tap()
        XCTAssertTrue(app.navigationBars["Listas"].waitForExistence(timeout: 5))

        app.buttons["tabbar.plus"].tap()
        XCTAssertTrue(app.navigationBars["Nueva lista"].waitForExistence(timeout: 5))

        let listName = "UI List \(UUID().uuidString.prefix(6))"
        let nameField = app.textFields["lists.create.nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText(listName)

        app.buttons["lists.create.confirmButton"].tap()
        XCTAssertTrue(app.staticTexts[listName].waitForExistence(timeout: 5))
    }

    func test_smoke_openLibraryStats() throws {
        XCTAssertTrue(app.navigationBars["Mi Biblioteca"].waitForExistence(timeout: 5))
        app.buttons["library.statsButton"].tap()
        XCTAssertTrue(app.navigationBars["Estadísticas"].waitForExistence(timeout: 5))
    }
}
