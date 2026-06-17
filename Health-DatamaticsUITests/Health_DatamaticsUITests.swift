//
//  Health_DatamaticsUITests.swift
//  Health-DatamaticsUITests
//
//  Created by Christopher Appiah-Thompson  on 17/6/2026.
//

import XCTest

final class Health_DatamaticsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testWorkbenchTabsAndReportsScreen() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Dashboard"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["dashboard-screen"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Quality"].tap()
        XCTAssertTrue(app.scrollViews["quality-screen"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Insights"].tap()
        XCTAssertTrue(app.scrollViews["insights-screen"].waitForExistence(timeout: 5))

        openTab(named: "Reports", in: app)
        XCTAssertTrue(app.scrollViews["reports-screen"].waitForExistence(timeout: 5))

        openTab(named: "Integrations", in: app)
        XCTAssertTrue(app.scrollViews["integrations-screen"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func openTab(named name: String, in app: XCUIApplication) {
        if app.tabBars.buttons[name].exists {
            app.tabBars.buttons[name].tap()
            return
        }

        app.tabBars.buttons["More"].tap()
        let tableLabel = app.tables.staticTexts[name]
        if tableLabel.waitForExistence(timeout: 5) {
            tableLabel.tap()
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
