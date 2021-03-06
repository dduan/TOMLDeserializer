#if !canImport(ObjectiveC)
import XCTest

extension ErrorTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ErrorTests = [
        ("testErrorFormatting", testErrorFormatting),
    ]
}

extension ScannerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ScannerTests = [
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
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__TOMLDeserializerTests = [
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

extension TOMLInvalidationTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__TOMLInvalidationTests = [
        ("test_array_7", test_array_7),
        ("test_array_mixed_types_arrays_and_ints", test_array_mixed_types_arrays_and_ints),
        ("test_array_mixed_types_ints_and_floats", test_array_mixed_types_ints_and_floats),
        ("test_array_mixed_types_strings_and_ints", test_array_mixed_types_strings_and_ints),
        ("test_array_of_tables_1", test_array_of_tables_1),
        ("test_array_of_tables_2", test_array_of_tables_2),
        ("test_bare_key_1", test_bare_key_1),
        ("test_bare_key_2", test_bare_key_2),
        ("test_bare_key_3", test_bare_key_3),
        ("test_datetime_malformed_no_leads", test_datetime_malformed_no_leads),
        ("test_datetime_malformed_no_secs", test_datetime_malformed_no_secs),
        ("test_datetime_malformed_no_t", test_datetime_malformed_no_t),
        ("test_datetime_malformed_with_milli", test_datetime_malformed_with_milli),
        ("test_duplicate_key_table", test_duplicate_key_table),
        ("test_duplicate_keys", test_duplicate_keys),
        ("test_duplicate_tables", test_duplicate_tables),
        ("test_empty_implicit_table", test_empty_implicit_table),
        ("test_empty_table", test_empty_table),
        ("test_float_leading_zero_neg", test_float_leading_zero_neg),
        ("test_float_leading_zero_pos", test_float_leading_zero_pos),
        ("test_float_leading_zero", test_float_leading_zero),
        ("test_float_no_leading_zero", test_float_no_leading_zero),
        ("test_float_no_trailing_digits", test_float_no_trailing_digits),
        ("test_float_underscore_after_point", test_float_underscore_after_point),
        ("test_float_underscore_after", test_float_underscore_after),
        ("test_float_underscore_before_point", test_float_underscore_before_point),
        ("test_float_underscore_before", test_float_underscore_before),
        ("test_inline_table_linebreak", test_inline_table_linebreak),
        ("test_int_0_padded", test_int_0_padded),
        ("test_integer_leading_zero_neg", test_integer_leading_zero_neg),
        ("test_integer_leading_zero_pos", test_integer_leading_zero_pos),
        ("test_integer_leading_zero", test_integer_leading_zero),
        ("test_integer_underscore_after", test_integer_underscore_after),
        ("test_integer_underscore_before", test_integer_underscore_before),
        ("test_integer_underscore_double", test_integer_underscore_double),
        ("test_key_after_array", test_key_after_array),
        ("test_key_after_table", test_key_after_table),
        ("test_key_empty", test_key_empty),
        ("test_key_hash", test_key_hash),
        ("test_key_newline", test_key_newline),
        ("test_key_no_eol", test_key_no_eol),
        ("test_key_open_bracket", test_key_open_bracket),
        ("test_key_single_open_bracket", test_key_single_open_bracket),
        ("test_key_space", test_key_space),
        ("test_key_start_bracket", test_key_start_bracket),
        ("test_key_two_equals", test_key_two_equals),
        ("test_key_value_pair_1", test_key_value_pair_1),
        ("test_llbrace", test_llbrace),
        ("test_multi_line_inline_table", test_multi_line_inline_table),
        ("test_multiple_dot_key", test_multiple_dot_key),
        ("test_multiple_key", test_multiple_key),
        ("test_no_key_name", test_no_key_name),
        ("test_non_dec_integers", test_non_dec_integers),
        ("test_rrbrace", test_rrbrace),
        ("test_string_bad_byte_escape", test_string_bad_byte_escape),
        ("test_string_bad_codepoint", test_string_bad_codepoint),
        ("test_string_bad_escape", test_string_bad_escape),
        ("test_string_bad_slash_escape", test_string_bad_slash_escape),
        ("test_string_bad_uni_esc", test_string_bad_uni_esc),
        ("test_string_basic_control_1", test_string_basic_control_1),
        ("test_string_basic_control_2", test_string_basic_control_2),
        ("test_string_basic_control_3", test_string_basic_control_3),
        ("test_string_basic_control_4", test_string_basic_control_4),
        ("test_string_basic_multiline_control_1", test_string_basic_multiline_control_1),
        ("test_string_basic_multiline_control_2", test_string_basic_multiline_control_2),
        ("test_string_basic_multiline_control_3", test_string_basic_multiline_control_3),
        ("test_string_basic_multiline_control_4", test_string_basic_multiline_control_4),
        ("test_string_basic_multiline_out_of_range_unicode_escape_1", test_string_basic_multiline_out_of_range_unicode_escape_1),
        ("test_string_basic_multiline_out_of_range_unicode_escape_2", test_string_basic_multiline_out_of_range_unicode_escape_2),
        ("test_string_basic_multiline_unknown_escape", test_string_basic_multiline_unknown_escape),
        ("test_string_basic_out_of_range_unicode_escape_1", test_string_basic_out_of_range_unicode_escape_1),
        ("test_string_basic_out_of_range_unicode_escape_2", test_string_basic_out_of_range_unicode_escape_2),
        ("test_string_basic_unknown_escape", test_string_basic_unknown_escape),
        ("test_string_byte_escapes", test_string_byte_escapes),
        ("test_string_literal_control_1", test_string_literal_control_1),
        ("test_string_literal_control_2", test_string_literal_control_2),
        ("test_string_literal_control_3", test_string_literal_control_3),
        ("test_string_literal_control_4", test_string_literal_control_4),
        ("test_string_literal_multiline_control_1", test_string_literal_multiline_control_1),
        ("test_string_literal_multiline_control_2", test_string_literal_multiline_control_2),
        ("test_string_literal_multiline_control_3", test_string_literal_multiline_control_3),
        ("test_string_literal_multiline_control_4", test_string_literal_multiline_control_4),
        ("test_string_no_close", test_string_no_close),
        ("test_table_1", test_table_1),
        ("test_table_2", test_table_2),
        ("test_table_array_implicit", test_table_array_implicit),
        ("test_table_array_malformed_bracket", test_table_array_malformed_bracket),
        ("test_table_array_malformed_empty", test_table_array_malformed_empty),
        ("test_table_empty", test_table_empty),
        ("test_table_nested_brackets_close", test_table_nested_brackets_close),
        ("test_table_nested_brackets_open", test_table_nested_brackets_open),
        ("test_table_whitespace", test_table_whitespace),
        ("test_table_with_pound", test_table_with_pound),
        ("test_text_after_array_entries", test_text_after_array_entries),
        ("test_text_after_integer", test_text_after_integer),
        ("test_text_after_string", test_text_after_string),
        ("test_text_after_table", test_text_after_table),
        ("test_text_before_array_separator", test_text_before_array_separator),
        ("test_text_in_array", test_text_in_array),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ErrorTests.__allTests__ErrorTests),
        testCase(ScannerTests.__allTests__ScannerTests),
        testCase(TOMLDeserializerTests.__allTests__TOMLDeserializerTests),
        testCase(TOMLInvalidationTests.__allTests__TOMLInvalidationTests),
    ]
}
#endif
