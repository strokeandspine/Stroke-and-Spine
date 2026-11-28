import XCTest

/// Walks through onboarding and the main screens, checking each one opens, and saves screenshots.
/// Run on the iPhone 16 Pro Max simulator to get 6.9-inch App Store screenshots (1320 × 2868).
final class AppWalkthroughUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
    }

    func testOnboardingTabsAndTreatmentOptions() throws {
        completeOnboarding()

        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 5))
        snapshot("01-Today")

        for (i, tab) in ["Exercise", "Medicines", "History"].enumerated() {
            app.tabBars.buttons[tab].tap()
            XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5), "\(tab) didn't open")
            snapshot("0\(i + 2)-\(tab)")
        }

        // Treatment options guide
        app.tabBars.buttons["More"].tap()
        tap(button("Treatment options and outcomes"))
        XCTAssertTrue(app.navigationBars["Treatment options"].waitForExistence(timeout: 5))
        snapshot("05-TreatmentOptions")

        // Browse one specialty
        tap(button("Vascular (arteries and veins)"))
        XCTAssertTrue(app.navigationBars["Vascular (arteries and veins)"].waitForExistence(timeout: 5))
        snapshot("06-Specialty")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Search for an operation and open its condition
        let search = app.searchFields.firstMatch
        if !search.exists { app.swipeDown() }
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("microdiscectomy")
        tap(button("Lumbar disc herniation with sciatica"))
        XCTAssertTrue(app.staticTexts["Don't wait — get help if"].waitForExistence(timeout: 5) || app.collectionViews.firstMatch.exists)
        snapshot("07-Condition")

        tap(button("Compare outcomes and side effects"))
        XCTAssertTrue(app.navigationBars["Compare options"].waitForExistence(timeout: 5))
        snapshot("08-Compare")

        tap(app.buttons["Serious risks"])
        snapshot("09-Compare-risks")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Open an option and save it to the discussion list
        tap(button("Microdiscectomy"))
        XCTAssertTrue(app.navigationBars["Microdiscectomy"].waitForExistence(timeout: 5))
        snapshot("10-Option")
        app.navigationBars["Microdiscectomy"].buttons["Save to discuss"].tap()
        XCTAssertTrue(app.navigationBars["Microdiscectomy"].buttons["Saved to discuss"].waitForExistence(timeout: 3))
        app.swipeUp()
        app.swipeUp()
        snapshot("11-Option-side-effects")
    }

    // MARK: - Helpers

    /// A button (including list navigation rows) whose accessibility label starts with the given text.
    private func button(_ prefix: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    private func completeOnboarding() {
        tap(app.buttons["Get started"])
        turnOn(app.switches["I am 18 or older"])
        turnOn(app.switches["I understand this app does not give medical advice and is not for emergencies"])
        tap(app.buttons["Continue"])
        let finish = app.buttons["Finish"]
        var tries = 0
        while !finish.isHittable && tries < 6 { app.swipeUp(); tries += 1 }
        finish.tap()
    }

    /// SwiftUI toggles in a Form only flip when the switch itself is tapped.
    private func turnOn(_ toggle: XCUIElement) {
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        let attempts: [() -> Void] = [
            { toggle.switches.firstMatch.tap() },                                              // inner UISwitch (iOS 17+)
            { toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap() },
            { toggle.tap() },
        ]
        for attempt in attempts where !isOn(toggle) {
            attempt()
            _ = toggle.waitForExistence(timeout: 1)
        }
        XCTAssertTrue(isOn(toggle), "Couldn't switch on \(toggle)")
    }

    private func isOn(_ toggle: XCUIElement) -> Bool {
        let value = toggle.value as? String
        return value == "1" || value?.lowercased() == "on"
    }

    /// Scrolls until the element is on screen, then taps it.
    private func tap(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing \(element)", file: file, line: line)
        var tries = 0
        while !element.isHittable && tries < 10 { app.swipeUp(); tries += 1 }
        element.tap()
    }

    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
