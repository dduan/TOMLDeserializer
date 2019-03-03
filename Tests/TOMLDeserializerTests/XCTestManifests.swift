import XCTest

extension ErrorTests {
    static let __allTests = [
        ("testErrorFormatting", testErrorFormatting),
    ]
}

extension ScannerTests {
    static let __allTests = [
        ("testDateExample", testDateExample),
        ("testExample", testExample),
        ("testFruit", testFruit),
        ("testHardExample", testHardExample),
        ("testHardUnicodeExample", testHardUnicodeExample),
        ("testInfinityAndNan", testInfinityAndNan),
        ("testInteger", testInteger),
        ("testMultilineString", testMultilineString),
        ("testNestedArrayTable", testNestedArrayTable),
        ("testNestedInlineTableArray", testNestedInlineTableArray),
        ("testParseArbitraryStuff", testParseArbitraryStuff),
        ("testPositionSeeking", testPositionSeeking),
        ("testRawMultilineString", testRawMultilineString),
        ("testScanner", testScanner),
        ("testTableArrayTableArray", testTableArrayTableArray),
        ("testValidKey", testValidKey),
    ]
}

extension TOMLDeserializerTests {
    static let __allTests = [
        ("test_array_empty", test_array_empty),
        ("test_array_nospaces", test_array_nospaces),
        ("test_array_string_quote_comma_2", test_array_string_quote_comma_2),
        ("test_array_string_quote_comma", test_array_string_quote_comma),
        ("test_array_string_with_comma", test_array_string_with_comma),
        ("test_array_table_array_string_backslash", test_array_table_array_string_backslash),
        ("test_arrays_hetergeneous", test_arrays_hetergeneous),
        ("test_arrays_nested", test_arrays_nested),
        ("test_arrays", test_arrays),
        ("test_bool", test_bool),
        ("test_comments_at_eof2", test_comments_at_eof2),
        ("test_comments_at_eof", test_comments_at_eof),
        ("test_comments_everywhere", test_comments_everywhere),
        ("test_datetime_timezone", test_datetime_timezone),
        ("test_datetime", test_datetime),
        ("test_dotted_keys", test_dotted_keys),
        ("test_double_quote_escape", test_double_quote_escape),
        ("test_empty", test_empty),
        ("test_escaped_escape", test_escaped_escape),
        ("test_example", test_example),
        ("test_exponent_part_float", test_exponent_part_float),
        ("test_float_exponent", test_float_exponent),
        ("test_float_underscore", test_float_underscore),
        ("test_float", test_float),
        ("test_implicit_and_explicit_after", test_implicit_and_explicit_after),
        ("test_implicit_and_explicit_before", test_implicit_and_explicit_before),
        ("test_implicit_groups", test_implicit_groups),
        ("test_infinity_and_nan", test_infinity_and_nan),
        ("test_inline_table_array", test_inline_table_array),
        ("test_inline_table", test_inline_table),
        ("test_integer_underscore", test_integer_underscore),
        ("test_integer", test_integer),
        ("test_key_equals_nospace", test_key_equals_nospace),
        ("test_key_numeric", test_key_numeric),
        ("test_key_space", test_key_space),
        ("test_key_special_chars", test_key_special_chars),
        ("test_keys_with_dots", test_keys_with_dots),
        ("test_local_date", test_local_date),
        ("test_local_datetime", test_local_datetime),
        ("test_local_time", test_local_time),
        ("test_long_float", test_long_float),
        ("test_long_integer", test_long_integer),
        ("test_multiline_string_accidental_whitespace", test_multiline_string_accidental_whitespace),
        ("test_multiline_string", test_multiline_string),
        ("test_newline_crlf", test_newline_crlf),
        ("test_newline_lf", test_newline_lf),
        ("test_non_dec_integers", test_non_dec_integers),
        ("test_raw_multiline_string", test_raw_multiline_string),
        ("test_raw_string", test_raw_string),
        ("test_string_empty", test_string_empty),
        ("test_string_escapes", test_string_escapes),
        ("test_string_nl", test_string_nl),
        ("test_string_simple", test_string_simple),
        ("test_string_with_pound", test_string_with_pound),
        ("test_table_array_implicit", test_table_array_implicit),
        ("test_table_array_many", test_table_array_many),
        ("test_table_array_nest", test_table_array_nest),
        ("test_table_array_one", test_table_array_one),
        ("test_table_array_table_array", test_table_array_table_array),
        ("test_table_empty", test_table_empty),
        ("test_table_no_eol", test_table_no_eol),
        ("test_table_sub_empty", test_table_sub_empty),
        ("test_table_whitespace", test_table_whitespace),
        ("test_table_with_literal_string", test_table_with_literal_string),
        ("test_table_with_pound", test_table_with_pound),
        ("test_table_with_single_quotes", test_table_with_single_quotes),
        ("test_underscored_float", test_underscored_float),
        ("test_underscored_integer", test_underscored_integer),
        ("test_unicode_escape", test_unicode_escape),
        ("test_unicode_literal", test_unicode_literal),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ErrorTests.__allTests),
        testCase(ScannerTests.__allTests),
        testCase(TOMLDeserializerTests.__allTests),
    ]
}
#endif
