struct Location: Equatable {
    let localText: String
    let line: Int
    let column: Int
    let bufferOffset: Int
}

extension Scanner {
    var cursorLocation: Location {
        let originalCursor = self.cursor
        defer { self.cursor = originalCursor }
        var line = 0
        var content = [CChar]()
        self.cursor = 0
        while self.cursor < originalCursor, case let next = self.next {
            if next == cNewline {
                content = []
                line += 1
            } else {
                content.append(next)
            }

            self.cursor += 1
        }

        let column = content.count

        while !self.isDone, case let next = self.next, next != cNewline && next != cCR {
            content.append(next)
            self.cursor += 1
        }

        let localText = String(terminatingCString: content)
        return Location(
            localText: localText,
            line: line + 1,
            column: max(0, column - 1),
            bufferOffset: max(0, originalCursor - 1)
        )
    }
}
