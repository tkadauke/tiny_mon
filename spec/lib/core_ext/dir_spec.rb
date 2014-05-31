require 'spec_helper'

describe Dir do
  describe ".create_tmp_dir" do
    let(:location) { "#{Rails.root}/tmp" }

    it "creates a temporary directory" do
      count = Dir.entries(location).size
      Dir.create_tmp_dir "foo", location do
        expect(Dir.entries(location).size).to eq(count + 1)
      end
    end

    it "cds into the directory" do
      pwd_before = Dir.pwd
      Dir.create_tmp_dir "foo", location do
        expect(Dir.pwd).not_to eq(pwd_before)
      end
    end

    it "cleans up the directory afterwards" do
      expect { Dir.create_tmp_dir("foo", location) {} }.not_to change { Dir.entries(location).size }
    end
  end
end
