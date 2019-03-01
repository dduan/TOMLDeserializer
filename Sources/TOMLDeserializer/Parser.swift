extension String: Error {}
extension Dictionary where Value == Any, Key == String {
    @discardableResult
    mutating func addIntoArray(at keys: [String]) throws -> Dictionary {
        if keys.count == 1, let key = keys.last {
            if var array = self[key] as? [[String: Any]] {
                array.append([String: Any]())
                self[key] = array
            } else if self[key] == nil {
                self[key] = [[String: Any]()]
            }
        } else if let key = keys.first {
            if self[key] == nil {
                var child = [String: Any]()
                self[key] = try child.addIntoArray(at: Array(keys.dropFirst()))
            } else if var child = self[key] as? [String: Any] {
                self[key] = try child.addIntoArray(at: Array(keys.dropFirst()))
            } else if let array = self[key] as? [[String: Any]], array.isEmpty {
                var table = [String: Any]()
                try table.addIntoArray(at: Array(keys.dropFirst()))
                self[key] = [table]
            } else if var array = self[key] as? [[String: Any]], var table = array.last {
                array[array.count - 1] = try table.addIntoArray(at: Array(keys.dropFirst()))
                self[key] = array
            }
        }

        return self
    }

    @discardableResult
    mutating func insert(at keys: [String], _ value: Any) throws -> Dictionary {
        assert(!keys.isEmpty)
        if keys.count == 1, let key = keys.last {
            if self[key] == nil {
                self[key] = value
            }
        } else if let key = keys.first {
            if self[key] == nil {
                var child = [String: Any]()
                self[key] = try child.insert(at: Array(keys.dropFirst()), value)
            } else if var child = self[key] as? [String: Any] {
                self[key] = try child.insert(at: Array(keys.dropFirst()), value)
            } else if let array = self[key] as? [[String: Any]], array.isEmpty {
                var table = [String: Any]()
                try table.insert(at: Array(keys.dropFirst()), value)
                self[key] = [table]
            } else if var array = self[key] as? [[String: Any]], var table = array.last {
                array[array.count - 1] = try table.insert(at: Array(keys.dropFirst()), value)
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
                try result.addIntoArray(at: self.activePath)
            } else if self.scanner.next == cOpenBracket {
                self.activePath = try self.scanner.takeTableHeader()
                try result.insert(at: self.activePath, [String: Any]())
            } else {
                let (keys, value) = try self.scanner.takeKeyValuePair()
                try result.insert(at: activePath + keys, value)
            }
        }

        return result
    }
}
