require 'spec_helper'

describe CheckRunsHelper do
  describe "#format_log_message" do
    context "given regular log message" do
      it "puts message in <code> tags" do
        message = helper.format_log_message('something')
        expect(message).to eq('<code>something</code>')
      end
    end

    context "given html page" do
      before { @message = helper.format_log_message('<html><body>hello</body></html>') }

      it "puts message in iframe" do
        expect(@message).to match(/iframe/)
      end

      it "escapes original message" do
        expect(@message).to match(%r{<html><body>hello<\\/body><\\/html>})
      end

      it "puts some javascript in there" do
        expect(@message).to match(%r{<script>})
      end
    end
  end
end
