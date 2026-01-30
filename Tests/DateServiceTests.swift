import XCTest
@testable import Bilalian

final class DateServiceTests: XCTestCase {
    func testDisplayStringsAreNotEmpty() {
        let display = DateService.shared.displayStrings(timeZone: .current)

        XCTAssertFalse(display.gregorian.isEmpty)
        XCTAssertFalse(display.hijri.isEmpty)
    }

    func testTimeStringIsNotEmpty() {
        let timeString = DateService.shared.timeString(timeZone: .current)

        XCTAssertFalse(timeString.isEmpty)
    }
}
