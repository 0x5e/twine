require 'twine_test_case'

class FormatterTest < TwineTestCase
  def setup(formatter_class)
    super()

    @twine_file = build_twine_file 'en' do
      add_section 'Section 1' do
        add_row key1: 'value1-english', comment: 'comment key1'
        add_row key2: 'value2-english'
      end

      add_section 'Section 2' do
        add_row key3: 'value3-english'
        add_row key4: 'value4-english', comment: 'comment key4'
      end
    end

    @strings = Twine::StringsFile.new
    @formatter = formatter_class.new @strings, { consume_all: true }
  end
end

class TestAndroidFormatter < FormatterTest
  def setup
    super Twine::Formatters::Android
  end

  def test_read_file_format
    @formatter.read_file fixture('formatter_android.xml'), 'en'

    1.upto(4) do |i|
      assert_equal "value#{i}-english", @strings.strings_map["key#{i}"].translations['en']
    end
  end

  def test_set_translation_transforms_leading_spaces
    @formatter.set_translation_for_key 'key1', 'en', "\u0020value"
    assert_equal ' value', @strings.strings_map['key1'].translations['en']
  end

  def test_set_translation_transforms_trailing_spaces
    @formatter.set_translation_for_key 'key1', 'en', "value\u0020\u0020"
    assert_equal 'value  ', @strings.strings_map['key1'].translations['en']
  end

  def test_write_file_output_format
    formatter = Twine::Formatters::Android.new @twine_file, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_android.xml'), output_content
  end

  def test_format_key_with_space
    assert_equal 'key ', @formatter.format_key('key ')
  end

  def test_format_value_with_leading_space
    assert_equal "\\u0020value", @formatter.format_value(' value')
  end

  def test_format_value_with_trailing_space
    assert_equal "value\\u0020", @formatter.format_value('value ')
  end

  def test_format_value_escapes_single_quotes
    skip 'not working with ruby 2.0'
    # http://stackoverflow.com/questions/18735608/cgiescapehtml-is-escaping-single-quote
    assert_equal "not \\'so\\' easy", @formatter.format_value("not 'so' easy")
  end

  def test_format_value_transforms_string_placeholder
    assert_equal '%s', @formatter.format_value('%@')
  end

  def test_format_value_transforms_ordered_string_placeholder
    assert_equal '%1s', @formatter.format_value('%1@')
  end

  def test_format_value_transforming_ordered_placeholders_maintains_order
    assert_equal '%2s %1d', @formatter.format_value('%2@ %1d')
  end

  def test_format_value_does_not_alter_double_percent
    assert_equal '%%d%%', @formatter.format_value('%%d%%')
  end

end

class TestAppleFormatter < FormatterTest
  def setup
    super Twine::Formatters::Apple
  end

  def test_read_file_format
    @formatter.read_file fixture('formatter_apple.strings'), 'en'

    1.upto(4) do |i|
      assert_equal "value#{i}-english", @strings.strings_map["key#{i}"].translations['en']
    end
  end

  def test_write_file_output_format
    formatter = Twine::Formatters::Apple.new @twine_file, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_apple.strings'), output_content
  end

  def test_format_key_with_space
    assert_equal 'key ', @formatter.format_key('key ')
  end

  def test_format_value_with_leading_space
    assert_equal ' value', @formatter.format_value(' value')
  end

  def test_format_value_with_trailing_space
    assert_equal 'value ', @formatter.format_value('value ')
  end
end

class TestJQueryFormatter < FormatterTest

  def setup
    super Twine::Formatters::JQuery
  end

  def test_read_file_format
    @formatter.read_file fixture('formatter_jquery.json'), 'en'

    1.upto(4) do |i|
      assert_equal "value#{i}-english", @strings.strings_map["key#{i}"].translations['en']
    end
  end

  def test_set_translation_escapes_newlines
    @formatter.set_translation_for_key 'key1', 'en', "new\nline"

    assert_equal 'new\nline', @strings.strings_map['key1'].translations['en']
  end

  def test_write_file_output_format
    formatter = Twine::Formatters::JQuery.new @twine_file, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_jquery.json'), output_content
  end

  def test_format_value_with_newline
    skip 'this test will only work once the JQuery formatter is modularized'
    # assert_equal "value\nwith\nline\nbreaks", @formatter.format_value("value\nwith\nline\nbreaks")
  end
end

class TestGettextFormatter < FormatterTest

  def setup
    super Twine::Formatters::Gettext
  end

  def test_read_file_format
    @formatter.read_file fixture('formatter_gettext.po'), 'en'

    1.upto(4) do |i|
      assert_equal "value#{i}-english", @strings.strings_map["key#{i}"].translations['en']
    end
  end

  def test_read_file_with_multiple_line_value
    @formatter.read_file fixture('gettext_multiline.po'), 'en'

    assert_equal 'multiline\nstring', @strings.strings_map['key1'].translations['en']
  end

  def test_write_file_output_format
    formatter = Twine::Formatters::Gettext.new @twine_file, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_gettext.po'), output_content
  end

end

class TestTizenFormatter < FormatterTest

  def setup
    super Twine::Formatters::Tizen
  end

  def test_read_file_format
    skip 'the current implementation of Tizen formatter does not support read_file'
    @formatter.read_file fixture('formatter_tizen.xml'), 'en'

    1.upto(4) do |i|
      assert_equal "value#{i}-english", @strings.strings_map["key#{i}"].translations['en']
    end
  end

  def test_write_file_output_format
    formatter = Twine::Formatters::Tizen.new @twine_file, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_tizen.xml'), output_content
  end

end

class TestDjangoFormatter < FormatterTest
  def setup
    super Twine::Formatters::Django
  end

  def test_read_file_format
    @formatter.read_file fixture('formatter_django.po'), 'en'

    1.upto(4) do |i|
      assert_equal "value#{i}-english", @strings.strings_map["key#{i}"].translations['en']
    end
  end

  def test_write_file_output_format
    formatter = Twine::Formatters::Django.new @twine_file, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_django.po'), output_content
  end
end

class TestFlashFormatter < FormatterTest
  def setup
    super Twine::Formatters::Flash
  end

  def test_read_file_format
    @formatter.read_file fixture('formatter_flash.properties'), 'en'

    1.upto(4) do |i|
      assert_equal "value#{i}-english", @strings.strings_map["key#{i}"].translations['en']
    end
  end

  def test_write_file_output_format
    formatter = Twine::Formatters::Flash.new @twine_file, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_flash.properties'), output_content
  end
end
