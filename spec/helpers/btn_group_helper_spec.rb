require 'spec_helper'

describe BtnGroupHelper do
  describe "#btn_group" do
    it "contains main link text" do
      result = helper.btn_group('foo', '/bar') {|b|}
      expect(result).to match(/foo/)
    end

    it "contains main link url" do
      result = helper.btn_group('foo', '/bar') {|b|}
      expect(result).to match(/bar/)
    end

    it "allows main link options" do
      result = helper.btn_group('foo', '/bar', :id => 'hello') {|b|}
      expect(result).to match(/hello/)
    end

    it "contains dropdown link text" do
      result = helper.btn_group('foo', '/bar') { |b| b.link_to 'acme', 'buzz' }
      expect(result).to match(/acme/)
    end

    it "contains dropdown link url" do
      result = helper.btn_group('foo', '/bar') { |b| b.link_to 'acme', 'buzz' }
      expect(result).to match(/buzz/)
    end

    it "allows dropdown link options" do
      result = helper.btn_group('foo', '/bar') { |b| b.link_to 'acme', 'buzz', :id => 'world' }
      expect(result).to match(/world/)
    end

    it "uses specified template" do
      result = helper.btn_group('foo', '/bar', :template => 'btn_menu') {|b|}
      expect(result).to match(/pull-right/)
    end
  end
end
