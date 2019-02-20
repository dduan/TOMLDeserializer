import XCTest

extension ScannerTests {
    static let __allTests = [
        ("testScanner", testScanner),
    ]
}

extension TOMLDeserializerTests {
    static let __allTests = [
        ("testDateExample", testDateExample),
        ("testExample", testExample),
        ("testFruit", testFruit),
        ("testHardExample", testHardExample),
        ("testHardUnicodeExample", testHardUnicodeExample),
        ("testInfinityAndNan", testInfinityAndNan),
        ("testMultilineString", testMultilineString),
        ("testNestedArrayTable", testNestedArrayTable),
        ("testParseArbitraryStuff", testParseArbitraryStuff),
        ("testRawMultilineString", testRawMultilineString),
        ("testTableArrayTableArray", testTableArrayTableArray),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ScannerTests.__allTests),
        testCase(TOMLDeserializerTests.__allTests),
    ]
}
#endif
