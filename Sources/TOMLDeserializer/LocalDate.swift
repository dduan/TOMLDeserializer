/// A date in Gregorian calendar, not specific to any timezone.
public struct LocalDate: Equatable, Codable {
    /// The year.
    public var year: Int16
    /// The month.
    public var month: Int8
    /// The day.
    public var day: Int8

    /// Creates a date from its components. If any of the componet value does
    /// not exist in the calendar, fail the creation.
    ///
    /// - Parameters:
    ///   - year: A year between 0000 and 9999.
    ///   - month: A month between 1 and 12.
    ///   - day: Day of the month.
    public init?<Y, M, D>(year: Y, month: M, day: D)
        where Y: SignedInteger, M: SignedInteger, D: SignedInteger
    {
        if year.isInvalidYear ||
            month.isInvalidMonth ||
            day.isInvalidDay(inYear: year, month: month)
        {
            return nil
        }

        self.year = Int16(year)
        self.month = Int8(month)
        self.day = Int8(day)
    }
}

extension SignedInteger {
    fileprivate var isInvalidYear: Bool {
        return self < 1 || self > 9999
    }

    fileprivate var isInvalidMonth: Bool {
        return self < 1 || self > 12
    }

    fileprivate func isInvalidDay<Y, M>(inYear year: Y, month: M) -> Bool
        where Y: SignedInteger, M: SignedInteger
    {
        let maxDayCount: Self
        let isLeapYear = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
        switch month {
        case 2:
            maxDayCount = isLeapYear ? 29 : 28
        case 4, 6, 9, 11:
            maxDayCount = 30
        default:
            maxDayCount = 31
        }

        return self < 1 || self > maxDayCount
    }
}

extension LocalDate: CustomStringConvertible {
    /// Serialized description of `LocalDate` in RFC 3339 format.
    public var description: String {
        let yearString: String
        if self.year < 10 {
            yearString = "000\(self.year)"
        } else if year < 100 {
            yearString = "00\(self.year)"
        } else if year < 1000 {
            yearString = "0\(self.year)"
        } else {
            yearString = String(self.year)
        }
        let monthString = "\(self.month > 9 ? "" : "0")\(self.month)"
        let dayString = "\(self.day > 9 ? "" : "0")\(self.day)"
        return "\(yearString)-\(monthString)-\(dayString)"
    }
}
