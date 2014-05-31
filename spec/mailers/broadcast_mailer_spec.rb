require 'spec_helper'

describe BroadcastMailer do
  let(:user) { create(:user) }
  let(:broadcast) { create(:broadcast) }

  describe "#broadcast" do
    let(:mail) { BroadcastMailer.broadcast(broadcast, user) }

    it "renders the subject" do
      expect(mail.subject).to match(broadcast.title)
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([user.email])
    end

    it "renders the sender email" do
      expect(mail.from.first).to match(/tinymon/)
    end

    it "assigns @broadcast" do
      expect(mail.body.encoded).to match(broadcast.text)
    end
  end
end
