public struct TOMLDeserializerError: Error, CustomStringConvertible {
    let summary: String
    let location: Location

    public var description: String {
        return """

        [TOMLDeserializer] Error: \(self.summary)
        Line \(self.location.line) Column \(self.location.column) Character \(self.location.bufferOffset):

        \(self.location.localText)

        """ + String(cString: [CChar](repeating: cSpace, count: self.location.column) + [cCaret, 0])
    }
}
