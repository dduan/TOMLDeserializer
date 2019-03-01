@testable import TOMLDeserializer
import XCTest

final class ErrorTests: XCTestCase {
    func testErrorFormatting() {
        let expected = """

        [TOMLDeserializer] Error: This is silly.
        Line 3 Column 9 Character 44:

        c = [ 1, 2, 3 ]
                 ^
        """

        let location = Location(localText: "c = [ 1, 2, 3 ]", line: 3, column: 9, bufferOffset: 44)
        XCTAssertEqual(
            expected,
            TOMLDeserializerError(summary: "This is silly.", location: location).description
        )
    }
}
