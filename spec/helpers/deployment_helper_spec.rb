require 'spec_helper'

describe DeploymentsHelper do
  describe "#deployment_title" do
    let(:deployment) { build(:deployment, :revision => '0123456789abcdef', :created_at => 50.seconds.ago) }

    it "contains revision" do
      result = helper.deployment_title(deployment)
      expect(result).to match(/01234567/)
    end

    it "contains time" do
      result = helper.deployment_title(deployment)
      expect(result).to match(/minute/)
    end
  end
end
