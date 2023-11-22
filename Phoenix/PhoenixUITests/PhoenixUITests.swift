//
//  PhoenixUITests.swift
//  PhoenixUITests
//
//  Created by Kaleb Rosborough on 2022-12-21.
//
import XCTest

final class PhoenixUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddGame() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()

        // Click the "plus" button
        let plusButtonQuery = app.buttons.matching(identifier: "New Game")
        if plusButtonQuery.count > 0 {
            let plusButton = plusButtonQuery.element(boundBy: 0)
            plusButton.click()
        }

        // Enter "nameForTestingUI" into the name field
        let nameField = app.textFields["Name Input"]
        nameField.click()
        nameField.typeText("nameForTestingUI")

        // Click the save button
        let saveButton = app.buttons["Save Game"]
        saveButton.click()

        app.terminate()
        app.launch()

        // Check if "nameForTestingUI" is still there (it should be)
        let nameLabel = app.staticTexts["nameForTestingUI"].firstMatch
        XCTAssertTrue(nameLabel.exists)

        // Delete the game by right clicking on it and clicking "Delete game button"
        nameLabel.rightClick()
        app.outlines.menuItems["Delete game"].click() // Delete Game is an accessibility identifier not the actual text
        // Quit the app and relaunch it
        app.terminate()
        app.launch()

        // Check if "nameForTestingUI" is still there (it should not be)
        XCTAssertFalse(nameLabel.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 13, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
