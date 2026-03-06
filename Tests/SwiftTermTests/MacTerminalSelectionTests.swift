#if os(macOS)
import XCTest

@testable import SwiftTerm

final class MacTerminalSelectionTests: XCTestCase {
    func testShouldClearSelectionOnLinefeedWhenMouseReportingAppIsActive() {
        XCTAssertTrue(
            TerminalView.shouldClearSelectionOnLinefeed(
                allowMouseReporting: true,
                mouseMode: .vt200
            )
        )
    }

    func testShouldNotClearSelectionOnLinefeedWhenMouseModeIsOff() {
        XCTAssertFalse(
            TerminalView.shouldClearSelectionOnLinefeed(
                allowMouseReporting: true,
                mouseMode: .off
            )
        )
    }

    func testLinefeedPreservesSelectionForRegularCliOutput() {
        let view = TerminalView(frame: .zero)
        view.selection.startSelection(row: 0, col: 0)

        XCTAssertTrue(view.selection.active)
        XCTAssertEqual(view.terminal.mouseMode, .off)

        view.linefeed(source: view.terminal)

        XCTAssertTrue(view.selection.active)
    }
}
#endif
