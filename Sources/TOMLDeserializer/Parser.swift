extension Dictionary where Value == Any, Key == String {
    @discardableResult
    mutating func insert(at keys: [String], _ value: Any) throws -> Dictionary {
        assert(!keys.isEmpty)
        if keys.count == 1 {
            self[keys.last!] = value
        } else if keys.count > 1, case let key? = keys.first {
            if self[key] == nil {
                var child = [String: Any]()
                self[key] = try child.insert(at: Array(keys.dropFirst()), value)
            } else if var child = self[key] as? [String: Any] {
                self[key] = try child.insert(at: Array(keys.dropFirst()), value)
            } else if var array = self[key] as? [[String: Any]], var table = array.last {
                array[array.count - 1] = try table.insert(at: keys, value)
                self[key] = array
            }
        }

        return self
    }
}

final class Parser {
    private let scanner: Scanner
    private var activePath = [String]()

    init(text: String) {
        self.scanner = Scanner(text: text)
    }

    func parse() throws -> [String: Any] {
        self.scanner.cursor = 0
        var result = [String: Any]()
        while !self.scanner.isDone {
            try self.scanner.takeTrivia()
            if self.scanner.isDone {
                break
            }

            if self.scanner.peek("[[") {
                self.activePath = try self.scanner.takeArrayHeader()
            } else if self.scanner.next == cOpenBracket {
                self.activePath = try self.scanner.takeTableHeader()
            } else {
                let (keys, value) = try self.scanner.takeKeyValuePair()
                try result.insert(at: activePath + keys, value)
            }
        }

        return result
    }
}
