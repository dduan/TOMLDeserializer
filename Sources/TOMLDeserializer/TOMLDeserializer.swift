public enum TOMLDeserializer {
    public static func tomlTable(with text: String) throws -> [String: Any] {
        return try Parser(text: text).parse()
    }

    public static func tomlTable<Bytes>(with bytes: Bytes) throws -> [String: Any]
        where Bytes: Collection, Bytes.Element == UInt8
    {
        let text = String(cString: Array(bytes) + [0])
        return try Parser(text: text).parse()
    }
}
