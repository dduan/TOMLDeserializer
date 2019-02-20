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
            throw "Expected \(word)"
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

        let text = self.take(until: { $0 == cSingleQuote })
        if self.isDone {
            throw "Mal-formed literal string"
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
            self.take(until: { $0 == cSingleQuote })
            if self.isDone {
                throw "Mal-formed literal string"
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

    // TODO: newline without leading backslash should be invalid
    func takeBasicString() throws -> String {
        assert(self.next == cDoubleQuote)
        self.cursor += 1

        var text = ""
        while true {
            let segment = self.take(until: { $0 == cDoubleQuote || $0 == cBackslash })
            if self.isDone {
                throw "Mal-formed basic string"
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
            let segment = self.take(until: { $0 == cDoubleQuote || $0 == cBackslash })
            if self.isDone {
                throw "Mal-formed multi-line string"
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
            throw "Malformed escape sequence in string"
        }

        self.cursor += 1

        if self.cursor + 4 > self.buffer.count {
            throw "Malformed escape sequence in string, terminated too early"
        }

        var digits = [CChar]()
        guard
            isHexDigit(self.buffer[self.cursor]),
            isHexDigit(self.buffer[self.cursor + 1]),
            isHexDigit(self.buffer[self.cursor + 2]),
            isHexDigit(self.buffer[self.cursor + 3])
        else
        {
            throw "Malformed escape sequence in string"
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
            throw "Invalid code point"
        }

        self.cursor += digits.count
        return result
    }

    @discardableResult
    func takeComment() throws -> String {
        assert(self.next == cHashtag)

        let startingPoint = self.cursor
        repeat {
            self.cursor += 1
        } while !self.isDone && self.endOfLine == -1

        let result = String(terminatingCString: self.buffer[startingPoint ..< self.cursor])
        self.cursor += self.endOfLine
        return result
    }

    func takeNumber() throws -> Any {
        var sign: Int64 = 1
        if self.next == cMinus {
            sign = -1
            self.cursor += 1
        } else if self.next == cPlus {
            self.cursor += 1
        }

        if peek("nan") {
            self.cursor += 3
            return sign == 1 ? Double.nan : -.nan
        } else if peek("inf") {
            self.cursor += 3
            return sign == 1 ? Double.infinity : -.infinity
        }

        if self.next == c0 {
            let nextNext = self.buffer[self.cursor + 1]
            if nextNext == cx || nextNext == cX {
                return try sign * self.takeHexIntegerWithoutSign()
            } else if nextNext == co || nextNext == cO {
                return try sign * self.takeOctalIntegerWithoutSign()
            } else if nextNext == cb || nextNext == cB{
                return try sign * self.takeBinaryIntegerWithoutSign()
            }
        }

        let integerPart = try sign * self.takeDecimalIntegerWithoutSign()

        var fractionPart: Int64?
        if !self.isDone && self.next == cDot {
            self.cursor += 1
            fractionPart = try self.takeDecimalIntegerWithoutSign()
        }

        var exponentPart: Int64?
        if !self.isDone && (self.next == ce || self.next == cE) {
            self.cursor += 1

            var exponentSign: Int64 = 1
            if self.next == cPlus {
                self.cursor += 1
            } else if self.next == cMinus {
                exponentSign = -1
                self.cursor += 1
            }

            exponentPart = try exponentSign * self.takeDecimalIntegerWithoutSign()
        }

        if fractionPart == nil && exponentPart == nil {
            return integerPart
        }

        var finalFraction = Double(fractionPart ?? 0)
        while finalFraction >= 1 {
            finalFraction /= 10
        }

        let finalExponent = Double(exponentPart ?? 1)

        return (Double(integerPart) + finalFraction) * pow(10, finalExponent)
    }

    // Assume sign is already handled
    func takeInteger(isDigit: (CChar) -> Bool, shift: Int,  decimal: (CChar) -> Int64) throws -> Int64 {
        self.cursor += 2
        guard isDigit(self.next) else {
            throw "Mal-formatted integer"
        }

        var result: Int64 = 0
        while true {
            while !self.isDone && isDigit(self.next) {
                result = result << shift + decimal(self.next)
                self.cursor += 1
            }

            let eolCount = self.endOfLine
            if eolCount == -1 && self.next == cUnderscore {
                self.cursor += 1
                continue
            } else if eolCount == -1 {
                throw "Invalid character in integer"
            }

            self.cursor += eolCount
            break
        }


        return result

    }

    func takeDecimalIntegerWithoutSign() throws -> Int64 {
        guard isDecimalDigit(self.next) else {
            throw "Mal-formatted decimal integer"
        }

        var result: Int64 = 0
        while !self.isDone {
            while !self.isDone && isDecimalDigit(self.next) {
                result = result * 10 + Int64(self.next - c0)
                self.cursor += 1
            }

            if !self.isDone && self.next == cUnderscore {
                self.cursor += 1
                continue
            }

            break
        }

        return result
    }

    // Assume sign is already handled
    func takeHexIntegerWithoutSign() throws -> Int64 {
        assert(self.peek("0x") || self.peek("0X"))
        return try self.takeInteger(
            isDigit: isHexDigit,
            shift: 4,
            decimal: { Int64(decimalValueOfHex($0)) }
        )
    }

    // Assume sign is already handled
    func takeBinaryIntegerWithoutSign() throws -> Int64 {
        assert(self.peek("0b") || self.peek("0B"))
        return try self.takeInteger(
            isDigit: isBinaryDigit,
            shift: 1,
            decimal: { Int64($0 - c0) }
        )
    }

    // Assume sign is already handled
    func takeOctalIntegerWithoutSign() throws -> Int64 {
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
                try self.takeComment()
            } else {
                break
            }
        }

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
                throw "Invalid character in key"
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
            throw "Expected [[ at start of array of table section header"
        }
        self.cursor += 2
        self.take(while: isWhitespace)
        let keys = try self.takeKeys()
        self.take(while: isWhitespace)
        guard self.peek("]]") else {
            throw "Expected ]] at end of array of table section header"
        }
        self.cursor += 2
        return keys
    }

    func takeTableHeader() throws -> [String] {
        guard self.next == cOpenBracket else {
            throw "Expected open bracket in table section header"
        }
        self.cursor += 1
        self.take(while: isWhitespace)
        let keys = try self.takeKeys()
        self.take(while: isWhitespace)
        guard self.next == cCloseBracket else {
            throw "Expected close bracket in table section header"
        }
        self.cursor += 1
        return keys
    }

    func takeInlineTable() throws -> [String: Any] {
        guard self.next == cOpenBrace else {
            throw "Expected open brace at start of inline table"
        }

        self.cursor += 1

        var result = [String: Any]()

        while !self.isDone {
            self.take(while: isWhitespace)
            let (keys, value) = try self.takeKeyValuePair()
            try result.insert(at: keys, value)
            self.take(while: isWhitespace)
            if self.next == cComma {
                self.cursor += 1
            } else if self.next == cCloseBrace {
                self.cursor += 1
                break
            } else {
                throw "Malformed inline table"
            }
        }

        return result
    }

    func takeArray() throws -> [Any] {
        guard self.next == cOpenBracket else {
            throw "Expected open bracket at start of inline table"
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
            throw "Heteral genious array are not allowed"
        }

        return result
    }

    func takeValue() throws -> Any {
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
            while self.cursor + offset < self.buffer.count && self.buffer[self.cursor + offset] != cNewline {
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
            while self.cursor + offset < self.buffer.count && self.buffer[self.cursor + offset] != cNewline {
                offset += 1
            }

            let restOfLine = Array(self.buffer[self.cursor..<self.cursor + offset])

            if restOfLine.count >= 20, let dateTime = DateTime(asciiValues: restOfLine) {
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

        throw "Invalid value"
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
