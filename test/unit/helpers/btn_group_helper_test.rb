require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class BtnGroupHelperTest < ActionView::TestCase
  test "should contain main link text" do
    result = btn_group('foo', '/bar') {|b|}
    assert result =~ /foo/
  end

  test "should contain main link url" do
    result = btn_group('foo', '/bar') {|b|}
    assert result =~ /bar/
  end

  test "should allow main link options" do
    result = btn_group('foo', '/bar', :id => 'hello') {|b|}
    assert result =~ /hello/
  end

  test "should contain dropdown link text" do
    result = btn_group('foo', '/bar') { |b| b.link_to 'acme', 'buzz' }
    assert result =~ /acme/
  end

  test "should contain dropdown link url" do
    result = btn_group('foo', '/bar') { |b| b.link_to 'acme', 'buzz' }
    assert result =~ /buzz/
  end

  test "should allow dropdown link options" do
    result = btn_group('foo', '/bar') { |b| b.link_to 'acme', 'buzz', :id => 'world' }
    assert result =~ /world/
  end

  test "should use specified template" do
    result = btn_group('foo', '/bar', :template => 'btn_menu') {|b|}
    assert result =~ /pull-right/
  end
end
