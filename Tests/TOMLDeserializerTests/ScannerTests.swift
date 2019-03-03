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
        XCTAssertEqual(Scanner(text: "# this is a comment\r with a naughty carriage return\n").takeComment(),
                       "# this is a comment\r with a naughty carriage return")
        XCTAssertEqual(Scanner(text: "#").takeComment(), "#")
        XCTAssertEqual(try Scanner(text: "0xdeadbee_f").takeHexIntegerWithoutSign(),
                       Array("deadbeef".utf8CString.dropLast()))
        XCTAssertEqual(try Scanner(text: "0b01_01").takeBinaryIntegerWithoutSign(),
                       Array("0101".utf8CString.dropLast()))
        XCTAssertEqual(try Scanner(text: "0o0_171").takeOctalIntegerWithoutSign(),
                       Array("0171".utf8CString.dropLast()))
        XCTAssertEqual(try Scanner(text: "123_4560").takeDecimalIntegerWithoutSign(),
                       Array("1234560".utf8CString.dropLast()))
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

    func testPositionSeeking() throws {
        let text = """
        a = 2
        b = [ 2019-02-28T00:00:00Z ]
        c = [ 1, 2, 3 ]
        """

        let scanner = Scanner(text: text)
        scanner.cursor = text.count - 5

        XCTAssertEqual(
            scanner.cursorLocation,
            Location(localText: "c = [ 1, 2, 3 ]", line: 3, column: 9, bufferOffset: 44))
    }

    func testParseArbitraryStuff() throws {
        let input = """
        [a.b]
        c.d = false
        e = "hello"
        f = { g.h = 'hello', f = { f = true } }
        g = [ [true], ["a"] ]
        [[x.y]]
        z = 0B0101
        a = 0.162E3
        [[x.y]]
        z = 0B0101
        a = 2001-02-14T23:59:60-00:01
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testFruit() throws {
        let input = """
        [[fruit.blah]]
          name = "apple"
          [fruit.blah.physical]
            color = "red"
            shape = "round"
        [[fruit.blah]]
          name = "banana"
          [fruit.blah.physical]
            color = "yellow"
            shape = "bent"
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testExample() throws {
        let input = """
        # This is a TOML document. Boom.

        title = "TOML Example"

        [owner]
        name = "Tom Preston-Werner"
        organization = "GitHub"
        bio = "GitHub Cofounder & CEO\nLikes tater tots and beer."

        [database]
        server = "192.168.1.1"
        ports = [ 8001, 8001, 8002 ]
        connection_max = 5000
        enabled = true

        [servers]

          # You can indent as you please. Tabs or spaces. TOML don't care.
          [servers.alpha]
          ip = "10.0.0.1"
          dc = "eqdc10"

          [servers.beta]
          ip = "10.0.0.2"
          dc = "eqdc10"
          country = "中国" # This should be parsed as UTF-8

        [clients]
        data = [ ["gamma", "delta"], [1, 2] ] # just an update to make sure parsers support it

        # Line breaks are OK when inside arrays
        hosts = [
          "alpha",
          "omega"
        ]

        # Products

          [[products]]
          name = "Hammer"
          sku = 738594937

          [[products]]
          name = "Nail"
          sku = 284758393
          color = "gray"
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testHardExample() throws {
        let input = """
        # Test file for TOML
        # Only this one tries to emulate a TOML file written by a user of the kind of parser writers probably hate
        # This part you'll really hate
        [the]
        test_string = "You'll hate me after this - #"          # " Annoying, isn't it?
            [the.hard]
            test_array = [ "] ", " # "]      # ] There you go, parse this!
            test_array2 = [ "Test #11 ]proved that", "Experiment #9 was a success" ]
            # You didn't think it'd as easy as chucking out the last #, did you?
            another_test_string = " Same thing, but with a string #"
            harder_test_string = " And when \\"'s are in the string, along with # \\""   # "and comments are there too"
            # Things will get harder
                [the.hard."bit#"]
                "what?" = "You don't think some user won't do that?"
                multi_line_array = [
                    "]",
                    # ] Oh yes I did
                    ]
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testHardUnicodeExample() throws {
        let input = """
        # Tèƨƭ ƒïℓè ƒôř TÓM£
        # Óñℓ¥ ƭλïƨ ôñè ƭřïèƨ ƭô è₥úℓáƭè á TÓM£ ƒïℓè ωřïƭƭèñ β¥ á úƨèř ôƒ ƭλè ƙïñδ ôƒ ƥářƨèř ωřïƭèřƨ ƥřôβáβℓ¥ λáƭè
        # Tλïƨ ƥářƭ ¥ôú'ℓℓ řèáℓℓ¥ λáƭè
        [the]
        test_string = "Ýôú'ℓℓ λáƭè ₥è áƒƭèř ƭλïƨ - #"          # " Âññô¥ïñϱ, ïƨñ'ƭ ïƭ?
            [the.hard]
            test_array = [ "] ", " # "]      # ] Tλèřè ¥ôú ϱô, ƥářƨè ƭλïƨ!
            test_array2 = [ "Tèƨƭ #11 ]ƥřôƲèδ ƭλáƭ", "Éжƥèřï₥èñƭ #9 ωáƨ á ƨúççèƨƨ" ]
            # Ýôú δïδñ'ƭ ƭλïñƙ ïƭ'δ áƨ èáƨ¥ áƨ çλúçƙïñϱ ôúƭ ƭλè ℓáƨƭ #, δïδ ¥ôú?
            another_test_string = "§á₥è ƭλïñϱ, βúƭ ωïƭλ á ƨƭřïñϱ #"
            harder_test_string = " Âñδ ωλèñ \\"'ƨ ářè ïñ ƭλè ƨƭřïñϱ, áℓôñϱ ωïƭλ # \\""   # "áñδ çô₥₥èñƭƨ ářè ƭλèřè ƭôô"
            # Tλïñϱƨ ωïℓℓ ϱèƭ λářδèř
                [the.hard."βïƭ#"]
                "ωλáƭ?" = "Ýôú δôñ'ƭ ƭλïñƙ ƨô₥è úƨèř ωôñ'ƭ δô ƭλáƭ?"
                multi_line_array = [
                    "]",
                    # ] Óλ ¥èƨ Ì δïδ
                    ]
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testDateExample() throws {
        let input = """
        best-day-ever = 1987-07-05T17:45:00Z
        [numtheory]
        boring = false
        perfection = [6, 28, 496]
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testInfinityAndNan() throws {
        let input = """

        nan = nan
        nan_neg = -nan
        nan_plus = +nan
        infinity = inf
        infinity_neg = -inf
        infinity_plus = +inf

        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testNestedArrayTable() throws {
        let input = """
        [[albums]]
        name = "Born to Run"
          [[albums.songs]]
          name = "Jungleland"
          [[albums.songs]]
          name = "Meeting Across the River"
        [[albums]]
        name = "Born in the USA"
          [[albums.songs]]
          name = "Glory Days"
          [[albums.songs]]
          name = "Dancing in the Dark"
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testRawMultilineString() throws {
        let input = """
        oneline = '''This string has a ' quote character.'''
        firstnl = '''
        This string has a ' quote character.'''
        multiline = '''
        This string
        has ' a quote character
        and more than
        one newline
        in it.'''
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testMultilineString() throws {
        let input = """
        oneline = \"\"\"This string has a \" quote character.\"\"\"
        firstnl = \"\"\"
        This string has a \" quote character.\"\"\"
        multiline = \"\"\"
        This string
        has \" a quote character
        and more than
        one newline
        in it.\"\"\"
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testTableArrayTableArray() throws {
        let input = """
        [[a]]
            [[a.b]]
                [a.b.c]
                    d = "val0"
            [[a.b]]
                [a.b.c]
                    d = "val1"
        """

        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testValidKey() throws {
        let input = """
        ['a']
        [a.'b']
        [a.'b'.c]
        answer = 42
        """
        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testInteger() throws {
        let input = """
        answer = 42
        posanswer = +42
        neganswer = -42
        zero = 0\n
        """
        _ = try TOMLDeserializer.tomlTable(with: input)
    }

    func testNestedInlineTableArray() throws {
        let input = "a = [ { b = {} } ]"
        _ = try TOMLDeserializer.tomlTable(with: input)
    }
}
