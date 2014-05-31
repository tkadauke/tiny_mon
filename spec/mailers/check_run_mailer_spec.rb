require 'spec_helper'

describe CheckRunMailer do
  let(:user) { create(:user) }
  let(:check_run) { create(:check_run) }

  describe "#failure" do
    let(:mail) { CheckRunMailer.failure(check_run, user) }

    it "renders the subject" do
      expect(mail.subject).to match("failed")
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([user.email])
    end

    it "renders the sender email" do
      expect(mail.from.first).to match(/tinymon/)
    end

    it "assigns @check_run" do
      expect(mail.body.encoded).to match(check_run.health_check.name)
    end
  end

  describe "#success" do
    let(:mail) { CheckRunMailer.success(check_run, user) }

    it "renders the subject" do
      expect(mail.subject).to match("successful")
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([user.email])
    end

    it "renders the sender email" do
      expect(mail.from.first).to match(/tinymon/)
    end

    it "assigns @check_run" do
      expect(mail.body.encoded).to match(check_run.health_check.name)
    end
  end
end
