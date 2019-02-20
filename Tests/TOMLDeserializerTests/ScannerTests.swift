@testable import TOMLDeserializer
import NetTime
import XCTest

final class ScannerTests: XCTestCase {
    func testScanner() throws {
        XCTAssertEqual(try Scanner(text: "\"a\\\r\nb\"").takeBasicString(), "ab")
        XCTAssertEqual(try Scanner(text: "\"a b\\n c\\t\\u005c\"").takeBasicString(), "a b\n c\t\\")
        XCTAssertEqual(try Scanner(text: "\"\"").takeBasicString(), "")
        XCTAssertEqual(try Scanner(text: "'acd'").takeLiteralString(), "acd")
        XCTAssertEqual(try Scanner(text: "\"\"\"\"\"\"").takeMultilineBasicString(), "")
        XCTAssertEqual(try Scanner(text: "\"\"\"\n\"\"\"").takeMultilineBasicString(), "")
        XCTAssertEqual(try Scanner(text: "\"\"\"\r\n\"\"\"").takeMultilineBasicString(), "")
        XCTAssertEqual(try Scanner(text: "\"\"\"\r\n\na\nb\r\n\"\"\"").takeMultilineBasicString(), "\na\nb\r\n")
        XCTAssertEqual(try Scanner(text: "''''''").takeMultilineLiteralString(), "")
        XCTAssertEqual(try Scanner(text: "'''\n'''").takeMultilineLiteralString(), "")
        XCTAssertEqual(try Scanner(text: "'''\r\n'''").takeMultilineLiteralString(), "")
        XCTAssertEqual(try Scanner(text: "'''\r\na\\u0032\n\\t'''").takeMultilineLiteralString(), "a\\u0032\n\\t")
        XCTAssertEqual(try Scanner(text: "# this is a comment\r with a naughty carriage return\n").takeComment(),
                       "# this is a comment\r with a naughty carriage return")
        XCTAssertEqual(try Scanner(text: "#").takeComment(), "#")
        XCTAssertEqual(try Scanner(text: "0xdeadbee_f").takeHexIntegerWithoutSign(), 0xdeadbeef)
        XCTAssertEqual(try Scanner(text: "0b01_01").takeBinaryIntegerWithoutSign(), 0b0101)
        XCTAssertEqual(try Scanner(text: "0o0_171").takeOctalIntegerWithoutSign(), 0o0171)
        XCTAssertEqual(try Scanner(text: "123_4560").takeDecimalIntegerWithoutSign(), 1234560)
        XCTAssertTrue(try ["", "#", " #", " #  ", "# abc"].allSatisfy { try Scanner(text: $0).takeTrivia() == $0 })
        XCTAssertEqual(try Scanner(text: "a. b .cd.'e'.\"\\u000A\"").takeKeys(), ["a", "b", "cd", "e", "\n"])
        XCTAssertEqual(try Scanner(text: "[ a. 'b ' ]").takeTableHeader(), ["a", "b "])

        let (k, v) = try Scanner(text: "a.b=false").takeKeyValuePair()
        XCTAssertEqual(k, ["a", "b"])
        XCTAssertEqual(v as? Bool, false)
        XCTAssertEqual(try Scanner(text: "{ a = true, b = false }").takeInlineTable() as? [String: Bool],
                       ["a": true, "b": false])

        XCTAssertEqual(try Scanner(text: "[true, false  , true]").takeArray() as? [Bool],
                       [true, false, true])
        XCTAssertEqual(try Scanner(text: "[8000, 8001  , 8002]").takeArray() as? [Int64],
                       [8000, 8001, 8002])
        XCTAssertEqual(try Scanner(text: "[[a.b.c]]").takeArrayHeader(), ["a", "b", "c"])
        XCTAssertEqual(try Scanner(text: "0xdeadbee_f").takeNumber() as? Int64, 0xdeadbeef)
        XCTAssertEqual(try Scanner(text: "0b01_01").takeNumber() as? Int64, 0b0101)
        XCTAssertEqual(try Scanner(text: "0o0_171").takeNumber() as? Int64, 0o0171)
        XCTAssertEqual(try Scanner(text: "+0Xdeadbee_f").takeNumber() as? Int64, 0xdeadbeef)
        XCTAssertEqual(try Scanner(text: "+0B01_01").takeNumber() as? Int64, 0b0101)
        XCTAssertEqual(try Scanner(text: "+0O0_171").takeNumber() as? Int64, 0o0171)
        XCTAssertEqual(try Scanner(text: "-0xdeadbee_f").takeNumber() as? Int64, -0xdeadbeef)
        XCTAssertEqual(try Scanner(text: "-0b01_01").takeNumber() as? Int64, -0b0101)
        XCTAssertEqual(try Scanner(text: "-0o0_171").takeNumber() as? Int64, -0o0171)

        XCTAssertEqual(try Scanner(text: "+0.0").takeNumber() as? Double, 0)
        XCTAssertTrue((try Scanner(text: "-nan").takeNumber() as? Double)?.isNaN ?? false)
        XCTAssertEqual(try Scanner(text: "inf").takeNumber() as? Double, .infinity)
        XCTAssertEqual(try Scanner(text: "1E2").takeNumber() as? Double, 100)
        XCTAssertEqual(try Scanner(text: "2.1E2").takeNumber() as? Double, 210)
        XCTAssertEqual(try Scanner(text: "21E-2").takeNumber() as? Double, 0.21)
        let date = LocalDate(year: 2001, month: 2, day: 14)!
        let time = LocalTime(hour: 23, minute: 59, second: 60)!
        XCTAssertEqual(try Scanner(text: "23:59:60").takeValue() as? LocalTime, time)
        XCTAssertEqual(try Scanner(text: "2001-02-14").takeValue() as? LocalDate, date)
        XCTAssertEqual(try Scanner(text: "2001-02-14T23:59:60").takeValue() as? LocalDateTime,
                       LocalDateTime(date: date, time: time))
        XCTAssertEqual(try Scanner(text: "2001-02-14 23:59:60Z").takeValue() as? DateTime,
                       DateTime(date: date, time: time, utcOffset: .zero))
        let offset = TimeOffset(sign: .minus, hour: 0, minute: 1)!
        XCTAssertEqual(try Scanner(text: "2001-02-14T23:59:60-00:01").takeValue() as? DateTime,
                       DateTime(date: date, time: time, utcOffset: offset))
    }
}
