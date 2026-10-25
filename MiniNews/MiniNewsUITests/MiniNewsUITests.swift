//
//  MiniNewsUITests.swift
//  MiniNewsUITests
//
//  Created by Salih Ezin on 24.10.2026.
//

import XCTest

final class MiniNewsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testStorySelection() throws {
        let app = XCUIApplication()
        app.launch()
        let besiktas = app.buttons["Beşiktaş"]
        XCTAssertTrue(besiktas.waitForExistence(timeout: 10))
        XCTAssertEqual(besiktas.value as? String, "Seçili")
        let vlahovic = app.buttons["Vlahovic"]
        vlahovic.tap()
        XCTAssertTrue(vlahovic.isSelected)
        XCTAssertEqual(vlahovic.value as? String, "Seçili")
        XCTAssertEqual(besiktas.value as? String, "Daha önce görüntülendi")
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Vlahovic seçili ana sayfa"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
