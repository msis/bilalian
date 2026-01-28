import XCTest
@testable import Bilalian

final class DateServiceTests: XCTestCase {
    func testDisplayStringsAreNotEmpty() {
        let display = DateService.shared.displayStrings()

        XCTAssertFalse(display.gregorian.isEmpty)
        XCTAssertFalse(display.hijri.isEmpty)
    }

    func testTimeStringIsNotEmpty() {
        let timeString = DateService.shared.timeString()

        XCTAssertFalse(timeString.isEmpty)
    }
}
