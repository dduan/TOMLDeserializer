#if os(Linux)
import Glibc
#else
import Darwin
#endif

import NetTime

extension String {
    init<S>(terminatingCString buffer: S) where S: Sequence, S.Element == CChar {
        self.init(cString: Array(buffer) + [0])
    }
}

let singleEscapes = [
    cb          : "\u{8}",
    ct          : "\t",
    cn          : "\n",
    cf          : "\u{c}",
    cr          : "\r",
    cBackslash  : "\\",
    cDoubleQuote: "\"",
]

func isWhitespace(_ c: CChar) -> Bool {
    return c == cSpace || c == cTab
}

func isNewline(_ c: CChar) -> Bool {
    return c == cNewline || c == cCR
}

func isDecimalDigit(_ c: CChar) -> Bool {
    return c >= c0 && c <= c9
}

func isHexDigit(_ c: CChar) -> Bool {
    return c >= c0 && c <= c9 || c >= ca && c <= cf || c >= cA && c <= cF
}

func isOctalDigit(_ c: CChar) -> Bool {
    return c >= c0 && c <= c7
}

func isBinaryDigit(_ c: CChar) -> Bool {
    return c == c0 || c == c1
}

func isBareKeyCharacter(_ c: CChar) -> Bool {
    return c >= ca && c <= cz || c >= cA && c <= cZ || c >= c0 && c <= c9 || c == cMinus || c == cUnderscore
}

func isDateCharacter(_ c: CChar) -> Bool {
    return c >= c0 && c <= c9 || c == cMinus || c == cColon || c == cPlus || c == cSpace || c == cT || c == cZ || c == cDot
}

func decimalValueOfHex(_ c: CChar) -> Int {
    if c >= c0 && c <= c9 {
        return Int(c - c0)
    }

    if c >= ca && c <= cf {
        return Int(c - ca) + 10
    }

    if c >= cA && c <= cF {
        return Int(c - cA) + 10
    }

    return 0
}

func isControlCharacter(_ c: CChar) -> Bool {
    return (c >= 0x0000 && c <= 0x001f || c == 0x007f) && c != cNewline && c != cCR
}

final class Scanner {
    var cursor = 0
    var buffer: [CChar]

    var leftOver: Int {
        return self.buffer.count - self.cursor
    }

    var isDone: Bool {
        return self.cursor >= self.buffer.count
    }

    // None negative means the number of characters required to indicate EOL
    // -1 means not at end of line
    var endOfLine: Int {
        if self.isDone {
            return 0
        }

        if self.next == cNewline {
            return 1
        }

        if self.leftOver >= 2 && self.next == cCR && self.buffer[self.cursor + 1] == cNewline
        {
            return 2
        }

        if self.leftOver == 1 && self.next == cCR { // weird, but ok?
            return 1
        }

        return -1
    }

    var next: CChar {
        assert(self.cursor < self.buffer.count)
        return self.buffer[self.cursor]
    }

    init(text: String) {
        self.buffer = Array(text.utf8CString.dropLast())
    }

    @discardableResult
    func take(until condition: @escaping (CChar) -> Bool) -> String {
        var position = self.cursor
        while position < buffer.count && !condition(self.buffer[position]) {
            position += 1
        }

        defer { self.cursor = position }
        return String(terminatingCString: self.buffer[self.cursor ..< position])
    }

    @discardableResult
    func take(while condition: @escaping (CChar) -> Bool) -> String {
        var position = self.cursor
        while position < buffer.count && condition(self.buffer[position]) {
            position += 1
        }
        defer { self.cursor = position }
        return String(terminatingCString: self.buffer[self.cursor ..< position])
    }

    func take(_ word: String) throws {
        if peek(word) {
            self.cursor += word.utf8.count
        } else {
            throw TOMLDeserializerError(
                summary: "Expected \(word)",
                location: self.cursorLocation)
        }
    }

    func peek(_ word: String) -> Bool {
        if word.utf8.count > self.leftOver {
            return false
        }

        if zip(word.utf8, self.buffer[self.cursor...]).allSatisfy(==) {
            return true
        } else {
            return false
        }
    }

    func takeLiteralString() throws -> String {
        assert(self.next == cSingleQuote)
        self.cursor += 1

        let text = self.take(until: { $0 == cSingleQuote || isControlCharacter($0) })
        if self.isDone {
            throw TOMLDeserializerError(
                summary: "Malformed literal string",
                location: self.cursorLocation)
        }

        if isControlCharacter(self.next) {
            throw TOMLDeserializerError(
                summary: "Control characters must be escaped.",
                location: self.cursorLocation)
        }

        self.cursor += 1
        return text
    }

    func takeMultilineLiteralString() throws -> String {
        assert(self.peek("'''"))
        self.cursor += 3
        if case let eolCount = self.endOfLine, eolCount != -1 {
            self.cursor += eolCount
        }

        let startingPoint = self.cursor
        while !self.isDone {
            self.take(until: { $0 == cSingleQuote || isControlCharacter($0) })
            if self.isDone {
                throw TOMLDeserializerError(
                    summary: "Malformed literal string",
                    location: self.cursorLocation)
            }

            if isControlCharacter(self.next) {
                throw TOMLDeserializerError(
                    summary: "Control characters must be escaped.",
                    location: self.cursorLocation)
            }

            if self.buffer[self.cursor] == cSingleQuote,
                self.buffer[self.cursor + 1] == cSingleQuote,
                self.buffer[self.cursor + 2] == cSingleQuote
            {
                break
            } else {
                self.cursor += 1
            }
        }

        defer { self.cursor += 3 }

        return String(terminatingCString: self.buffer[startingPoint ..< self.cursor])
    }

    func takeBasicString() throws -> String {
        assert(self.next == cDoubleQuote)
        self.cursor += 1

        var text = ""
        while true {
            let segment = self.take(until: { $0 == cDoubleQuote || $0 == cBackslash || isControlCharacter($0) })
            if self.isDone {
                throw TOMLDeserializerError(
                    summary: "Malformed basic string",
                    location: self.cursorLocation)
            }

            if isControlCharacter(self.next) {
                throw TOMLDeserializerError(
                    summary: "Control characters must be escaped.",
                    location: self.cursorLocation)
            }

            text += segment

            if self.next == cDoubleQuote {
                break
            }

            if self.next == cBackslash {
                self.cursor += 1
                let eolCount = self.endOfLine
                if eolCount == 1 || eolCount == 2 { // line ending backslash
                    try self.takeTrivia()
                    continue
                } else {
                    self.cursor -= 1
                    text += try self.takeEscapeSequence()
                }
            }
        }

        self.cursor += 1

        return text
    }

    func takeMultilineBasicString() throws -> String {
        assert(self.peek("\"\"\""))
        self.cursor += 3
        if case let eolCount = self.endOfLine, eolCount != -1 {
            self.cursor += eolCount
        }

        var text = ""
        while !self.isDone {
            let segment = self.take(until: { $0 == cDoubleQuote || $0 == cBackslash || isControlCharacter($0) })
            if self.isDone {
                throw TOMLDeserializerError(
                    summary: "Malformed multi-line string",
                    location: self.cursorLocation)
            }

            if isControlCharacter(self.next) {
                throw TOMLDeserializerError(
                    summary: "Control characters must be escaped.",
                    location: self.cursorLocation)
            }

            text += segment

            if self.buffer[self.cursor] == cDoubleQuote,
                self.buffer[self.cursor + 1] == cDoubleQuote,
                self.buffer[self.cursor + 2] == cDoubleQuote
            {
                break
            }

            if self.next == cDoubleQuote {
                text += "\""
                self.cursor += 1
            }

            if self.next == cBackslash {
                self.cursor += 1
                let eolCount = self.endOfLine
                if eolCount == 1 || eolCount == 2 { // line ending backslash
                    try self.takeTrivia()
                    continue
                } else {
                    self.cursor -= 1
                    text += try self.takeEscapeSequence()
                }
            }
        }

        self.cursor += 3

        return text
    }

    func takeEscapeSequence() throws -> String {
        assert(self.next == cBackslash)
        self.cursor += 1
        if let single = singleEscapes[self.next] {
            self.cursor += 1
            return single
        }

        guard self.next == cu || self.next == cU else {
            throw TOMLDeserializerError(
                summary: "Malformed escape sequence in string",
                location: self.cursorLocation)
        }

        self.cursor += 1

        if self.cursor + 4 > self.buffer.count {
            throw TOMLDeserializerError(
                summary: "Malformed escape sequence in string, terminated too early",
                location: self.cursorLocation)
        }

        var digits = [CChar]()
        guard
            isHexDigit(self.buffer[self.cursor]),
            isHexDigit(self.buffer[self.cursor + 1]),
            isHexDigit(self.buffer[self.cursor + 2]),
            isHexDigit(self.buffer[self.cursor + 3])
        else
        {
            throw TOMLDeserializerError(
                summary: "Malformed escape sequence in string",
                location: self.cursorLocation)
        }

        digits += self.buffer[self.cursor ..< self.cursor + 4]

        if self.cursor + 8 < self.buffer.count &&
            isHexDigit(self.buffer[self.cursor + 4]) &&
            isHexDigit(self.buffer[self.cursor + 5]) &&
            isHexDigit(self.buffer[self.cursor + 6]) &&
            isHexDigit(self.buffer[self.cursor + 7])
        {
            digits += self.buffer[self.cursor + 4 ..< self.cursor + 8]
        }

        let value = digits.reduce(0) { $0 << 4 + decimalValueOfHex($1) }
        guard let result = UnicodeScalar(value).map(String.init) else {
            throw TOMLDeserializerError(
                summary: "Invalid code point",
                location: self.cursorLocation)
        }

        self.cursor += digits.count
        return result
    }

    @discardableResult
    func takeComment() -> String {
        assert(self.next == cHashtag)

        let startingPoint = self.cursor
        repeat {
            self.cursor += 1
        } while !self.isDone && self.endOfLine == -1

        let result = String(terminatingCString: self.buffer[startingPoint ..< self.cursor])
        return result
    }

    func takeNumber() throws -> Any {
        var sign: CChar = cPlus
        if self.next == cMinus {
            sign = cMinus
            self.cursor += 1
        } else if self.next == cPlus {
            self.cursor += 1
        }

        if peek("nan") {
            self.cursor += 3
            return sign == cPlus ? Double.nan : -.nan
        } else if peek("inf") {
            self.cursor += 3
            return sign == cPlus ? Double.infinity : -.infinity
        }

        let hasLeadingZero = self.next == c0
        if hasLeadingZero {
            let nextNext = self.buffer[self.cursor + 1]
            if nextNext == cx || nextNext == cX {
                let text = try String(terminatingCString: [sign] + self.takeHexIntegerWithoutSign())
                return Int64(text, radix: 16) ?? 0
            } else if nextNext == co || nextNext == cO {
                let text = try String(terminatingCString: [sign] + self.takeOctalIntegerWithoutSign())
                return Int64(text, radix: 8) ?? 0
            } else if nextNext == cb || nextNext == cB{
                let text = try String(terminatingCString: [sign] + self.takeBinaryIntegerWithoutSign())
                return Int64(text, radix: 2) ?? 0
            }

        }

        let integerPart = try self.takeDecimalIntegerWithoutSign()
        if hasLeadingZero && integerPart.count != 1 {
            throw TOMLDeserializerError(
                summary: "Leading zero are not allowed in numbers.",
                location: self.cursorLocation)
        }

        var fractionPart = [CChar]()
        if !self.isDone && self.next == cDot {
            self.cursor += 1
            fractionPart = try self.takeDecimalIntegerWithoutSign()
        }

        var exponentPart = [CChar]()
        if !self.isDone && (self.next == ce || self.next == cE) {
            self.cursor += 1

            var exponentSign = cPlus
            if self.next == cPlus {
                self.cursor += 1
            } else if self.next == cMinus {
                exponentSign = cMinus
                self.cursor += 1
            }

            exponentPart = try [exponentSign] + self.takeDecimalIntegerWithoutSign()
        }

        if fractionPart.isEmpty && exponentPart.isEmpty {
            let text = String(terminatingCString: [sign] + integerPart)

            guard let integer = Int64(text) else {
                throw TOMLDeserializerError(
                    summary: "Invalid characters in integer.",
                    location: self.cursorLocation)
            }

            return integer
        }

        if !fractionPart.isEmpty {
            fractionPart = [cDot] + fractionPart
        }

        if !exponentPart.isEmpty {
            exponentPart = [cE] + exponentPart
        }

        let text = String(terminatingCString: [sign] + integerPart + fractionPart + exponentPart)
        guard let double = Double(text) else {
            throw TOMLDeserializerError(
                summary: "Invalid characters in floating number.",
                location: self.cursorLocation)
        }

        return double
    }

    // Assume sign is already handled
    func takeInteger(isDigit: (CChar) -> Bool, shift: Int,  decimal: (CChar) -> Int64) throws -> [CChar] {
        self.cursor += 2
        guard isDigit(self.next) else {
            throw TOMLDeserializerError(
                summary: "Mal-formatted integer",
                location: self.cursorLocation)
        }

        var digits = [CChar]()
        while true {
            while !self.isDone && isDigit(self.next) {
                digits.append(self.next)
                self.cursor += 1
            }

            let eolCount = self.endOfLine
            if eolCount == -1 && self.next == cUnderscore {
                self.cursor += 1
                continue
            } else if eolCount == -1 {
                throw TOMLDeserializerError(
                    summary: "Invalid character in integer",
                    location: self.cursorLocation)
            }

            break
        }


        return digits

    }

    func takeDecimalIntegerWithoutSign() throws -> [CChar] {
        guard isDecimalDigit(self.next) else {
            throw TOMLDeserializerError(
                summary: "Mal-formatted decimal integer",
                location: self.cursorLocation)
        }

        var digits = [CChar]()
        var justSawUnderscore = false
        while !self.isDone {

            while !self.isDone && isDecimalDigit(self.next) {
                digits.append(self.next)
                self.cursor += 1
                justSawUnderscore = false
            }

            if !self.isDone && self.next == cUnderscore {
                if justSawUnderscore {
                    throw TOMLDeserializerError(
                        summary: "Unexpected '_' in number.",
                        location: self.cursorLocation)
                }

                self.cursor += 1
                justSawUnderscore = true
                continue
            }

            if justSawUnderscore {
                throw TOMLDeserializerError(
                    summary: "Unexpected '_' in number.",
                    location: self.cursorLocation)
            }

            break
        }

        return digits
    }

    // Assume sign is already handled
    func takeHexIntegerWithoutSign() throws -> [CChar] {
        assert(self.peek("0x") || self.peek("0X"))
        return try self.takeInteger(
            isDigit: isHexDigit,
            shift: 4,
            decimal: { Int64(decimalValueOfHex($0)) }
        )
    }

    // Assume sign is already handled
    func takeBinaryIntegerWithoutSign() throws -> [CChar] {
        assert(self.peek("0b") || self.peek("0B"))
        return try self.takeInteger(
            isDigit: isBinaryDigit,
            shift: 1,
            decimal: { Int64($0 - c0) }
        )
    }

    // Assume sign is already handled
    func takeOctalIntegerWithoutSign() throws -> [CChar] {
        assert(self.peek("0o") || self.peek("0O"))
        return try self.takeInteger(
            isDigit: isOctalDigit,
            shift: 3,
            decimal: { Int64($0 - c0) }
        )
    }

    @discardableResult
    func takeTrivia() throws -> String {
        let startingPoint = self.cursor
        while !self.isDone {
            if isWhitespace(self.next) {
                self.take(while: isWhitespace)
            } else if isNewline(self.next) {
                self.take(while: isNewline)
            } else if self.next == cHashtag {
                self.takeComment()
            } else {
                break
            }
        }

        return String(terminatingCString: self.buffer[startingPoint ..< self.cursor])
    }

    @discardableResult
    func takeTriviaUntilEndOfLine() throws -> String {
        let startingPoint = self.cursor
        while !self.isDone {
            if isWhitespace(self.next) {
                self.take(while: isWhitespace)
            } else if self.next == cHashtag {
                self.takeComment()
            } else {
                break
            }
        }

        let eolCount = self.endOfLine
        if eolCount == -1 && !self.isDone {
            throw TOMLDeserializerError(
                summary: "Unexpected characters.",
                location: self.cursorLocation)
        }

        defer { self.cursor += eolCount }

        return String(terminatingCString: self.buffer[startingPoint ..< self.cursor])
    }

    func takeKeys() throws -> [String] {
        var result = [String]()
        while !self.isDone {
            if isBareKeyCharacter(self.next) {
                result.append(self.take(while: isBareKeyCharacter))
            } else if self.next == cDoubleQuote {
                try result.append(self.takeBasicString())
            } else if self.next == cSingleQuote {
                try result.append(self.takeLiteralString())
            } else {
                throw TOMLDeserializerError(
                    summary: "Invalid character in key",
                    location: self.cursorLocation)
            }

            self.take(while: isWhitespace)
            if !self.isDone && self.next == cDot {
                self.cursor += 1
            } else {
                break
            }
            self.take(while: isWhitespace)
        }

        return result
    }

    func takeArrayHeader() throws -> [String] {
        guard self.peek("[[") else {
            throw TOMLDeserializerError(
                summary: "Expected [[ at start of array of table section header",
                location: self.cursorLocation)
        }
        self.cursor += 2
        self.take(while: isWhitespace)
        let keys = try self.takeKeys()
        self.take(while: isWhitespace)
        guard self.peek("]]") else {
            throw TOMLDeserializerError(
                summary: "Expected ]] at end of array of table section header",
                location: self.cursorLocation)
        }
        self.cursor += 2

        try self.takeTriviaUntilEndOfLine()
        return keys
    }

    func takeTableHeader() throws -> [String] {
        guard self.next == cOpenBracket else {
            throw TOMLDeserializerError(
                summary: "Expected open bracket in table section header",
                location: self.cursorLocation)
        }
        self.cursor += 1
        self.take(while: isWhitespace)
        let keys = try self.takeKeys()
        self.take(while: isWhitespace)
        guard !self.isDone && self.next == cCloseBracket else {
            throw TOMLDeserializerError(
                summary: "Expected close bracket in table section header",
                location: self.cursorLocation)
        }
        self.cursor += 1

        try self.takeTriviaUntilEndOfLine()
        return keys
    }

    func takeInlineTable() throws -> [String: Any] {
        guard self.next == cOpenBrace else {
            throw TOMLDeserializerError(
                summary: "Expected open brace at start of inline table",
                location: self.cursorLocation)
        }

        self.cursor += 1

        var result = [String: Any]()

        while !self.isDone {
            self.take(while: isWhitespace)
            if self.next == cCloseBrace {
                self.cursor += 1
                break
            }

            let (keys, value) = try self.takeKeyValuePair()
            try result.insert(at: keys, value)
            self.take(while: isWhitespace)
            if self.next == cComma {
                self.cursor += 1
            } else if self.next == cCloseBrace {
                self.cursor += 1
                break
            } else {
                throw TOMLDeserializerError(
                    summary: "Malformed inline table",
                    location: self.cursorLocation)
            }
        }

        return result
    }

    func takeArray() throws -> [Any] {
        guard self.next == cOpenBracket else {
            throw TOMLDeserializerError(
                summary: "Expected open bracket at start of inline table",
                location: self.cursorLocation)
        }

        self.cursor += 1

        var result = [Any]()
        while !self.isDone {
            try self.takeTrivia()
            if self.next == cCloseBracket {
                self.cursor += 1
                break
            } else {
                result.append(try self.takeValue())
                try self.takeTrivia()
                if self.next == cComma {
                    self.cursor += 1
                }
            }
        }

        if result.isEmpty {
            return result
        }

        let allArray = result.allSatisfy { $0 is [Any] }
        let allDictionary = result.allSatisfy { $0 is [String: Any] }
        let allSame = zip(result, result.dropFirst()).allSatisfy { type(of: $0) == type(of: $1) }

        if !allArray && !allDictionary && !allSame {
            throw TOMLDeserializerError(
                summary: "Heteral genious array are not allowed",
                location: self.cursorLocation)
        }

        return result
    }

    func takeValue() throws -> Any {
        guard !self.isDone else {
            throw TOMLDeserializerError(
                summary: "Unexpected end of file",
                location: self.cursorLocation)
        }

        let leftOver = self.leftOver
        if self.next == cf {
            try self.take("false")
            return false
        }

        if self.next == ct {
            try self.take("true")
            return true
        }

        if self.peek("'''") {
            return try self.takeMultilineLiteralString()
        }

        if self.peek("\"\"\"") {
            return try self.takeMultilineBasicString()
        }

        if self.next == cDoubleQuote {
            return try self.takeBasicString()
        }

        if self.next == cSingleQuote {
            return try self.takeLiteralString()
        }

        if self.next == cOpenBrace {
            return try self.takeInlineTable()
        }

        if self.next == cOpenBracket {
            return try self.takeArray()
        }

        if leftOver >= 8 &&
            self.buffer[self.cursor + 2] == cColon &&
            self.buffer[self.cursor + 5] == cColon
        {
            var offset = 0
            while self.cursor + offset < self.buffer.count && isDateCharacter(self.buffer[self.cursor + offset]) {
                offset += 1
            }

            let restOfLine = Array(self.buffer[self.cursor..<self.cursor + offset])
            if let time = LocalTime(asciiValues: restOfLine) {
                self.cursor += time.description.count
                return time
            }
        }

        if leftOver >= 10 &&
            self.buffer[self.cursor + 4] == cMinus &&
            self.buffer[self.cursor + 7] == cMinus
        {
            var offset = 0
            while self.cursor + offset < self.buffer.count && isDateCharacter(self.buffer[self.cursor + offset]) {
                offset += 1
            }

            let restOfLine = Array(self.buffer[self.cursor..<self.cursor + offset])

            if let dateTime = DateTime(asciiValues: restOfLine) {
                self.cursor += dateTime.description.count
                return dateTime
            }

            if restOfLine.count >= 19, let dateTime = LocalDateTime(asciiValues: restOfLine) {
                self.cursor += dateTime.description.count
                return dateTime
            }

            if let date = LocalDate(asciiValues: restOfLine) {
                self.cursor += date.description.count
                return date
            }
        }

        if self.next >= c0 && self.next <= c9 || self.next == cMinus || self.next == cPlus {
            return try self.takeNumber()
        }

        if peek("nan") {
            self.cursor += 3
            return Double.nan
        } else if peek("inf") {
            self.cursor += 3
            return Double.infinity
        }

        throw TOMLDeserializerError(
            summary: "Invalid value",
            location: self.cursorLocation)
    }

    func takeKeyValuePair() throws -> ([String], Any) {
        let keys = try self.takeKeys()
        self.take(while: isWhitespace)
        try self.take("=")
        self.take(while: isWhitespace)
        let value = try self.takeValue()
        return (keys, value)
    }
}
