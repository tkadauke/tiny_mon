require 'spec_helper'

describe Broadcast do
  let(:broadcast) { create(:broadcast) }

  describe "#valid?" do
    it "is false by default" do
      expect(Broadcast.new).to be_invalid
    end

    it "is valid with title and text" do
      expect(Broadcast.new(:title => 'Hello', :text => 'World')).to be_valid
    end
  end

  describe "#name" do
    it "equals title" do
      expect(Broadcast.new(:title => 'Hello').name).to eq('Hello')
    end
  end

  describe ".from_param!" do
    it "finds broadcast by ID" do
      expect(Broadcast.from_param!(broadcast.id)).to eq(broadcast)
    end
  end

  describe "#deliver" do
    before { @users = create_list(:user, 5) }

    it "sends a mail to each user" do
      expect(BroadcastMailer).to receive(:broadcast).exactly(5).times
      broadcast.deliver
    end

    it "skips users that opted out" do
      @users.last.config.update_attributes(:broadcasts_enabled => false)
      expect(BroadcastMailer).to receive(:broadcast).exactly(4).times
      broadcast.deliver
    end

    it "updates sent_at timestamp" do
      expect { broadcast.deliver }.to change { broadcast.reload.sent_at }
    end

    it "runs in background" do
      expect(broadcast).to respond_to(:deliver_with_background)
    end
  end
end
