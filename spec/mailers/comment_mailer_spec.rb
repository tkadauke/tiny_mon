require 'spec_helper'

describe CommentMailer do
  let(:user) { create(:user) }
  let(:comment) { create(:comment) }

  describe "#comment" do
    let(:mail) { CommentMailer.comment(comment, user) }

    it "renders the subject" do
      expect(mail.subject).to match("Comment")
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([user.email])
    end

    it "renders the sender email" do
      expect(mail.from.first).to match(/tinymon/)
    end

    it "assigns @comment" do
      expect(mail.body.encoded).to match(comment.user.full_name)
    end
  end
end
