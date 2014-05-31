require 'spec_helper'

describe PasswordResetsMailer do
  let(:user) { create(:user) }

  describe "#password_reset_instructions" do
    let(:mail) { PasswordResetsMailer.password_reset_instructions(user) }

    it "renders the subject" do
      expect(mail.subject).to match(/instructions/i)
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([user.email])
    end

    it "renders the sender email" do
      expect(mail.from.first).to match(/tinymon/)
    end

    it "assigns @edit_password_reset_path" do
      expect(mail.body.encoded).to match(user.perishable_token)
    end
  end
end
