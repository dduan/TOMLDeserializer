/// A moment in time in a unspecifed time zone. The era is assumed to be
/// the current era. Dates and time are in accordance to the Gregorian calendar.
///
/// This type is designed to preserves information as defined in [RFC 3339][] as
/// much as poosible.
///
/// [RFC 3339]: https://tools.ietf.org/html/rfc3339
public struct LocalDateTime: Equatable, Codable {
    /// Year, month, day potion of the moment.
    public var date: LocalDate
    /// Hour, minute, second, sub-second potion of the moment.
    public var time: LocalTime

    /// Create a `DateTime`.
    ///
    /// - Parameters:
    ///   - date: The date potion of the moment.
    ///   - time: The time potion of the moment.
    public init(date: LocalDate, time: LocalTime) {
        self.date = date
        self.time = time
    }
}

extension LocalDateTime: CustomStringConvertible {
    /// Serialized description of `LocalDateTime` in RFC 3339 format.
    public var description: String {
        return "\(self.date)T\(self.time)"
    }
}
