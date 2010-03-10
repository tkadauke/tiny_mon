require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CheckRunsHelperTest < ActionView::TestCase
  test "should format normal log message" do
    message = format_log_message('something')
    assert_equal '<code>something</code>', message
  end
  
  test "should format html page log message" do
    message = format_log_message('<html><body>hello</body></html>')
    assert message =~ /iframe/
    assert message =~ /<html><body>hello<\\\/body><\\\/html>/
  end
end
