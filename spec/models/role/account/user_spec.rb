require 'spec_helper'

describe Role::Account::User do
  class TestUserAccount
    include Role::Account::User
  end

  let(:user) { TestUserAccount.new }

  it "can create health checks" do
    expect(user.can_create_health_checks?).to be_true
  end

  it "can edit health checks" do
    expect(user.can_edit_health_checks?).to be_true
  end

  it "can delete health checks" do
    expect(user.can_delete_health_checks?).to be_true
  end

  it "can run health checks" do
    expect(user.can_run_health_checks?).to be_true
  end

  it "can create sites" do
    expect(user.can_create_sites?).to be_true
  end

  it "can edit sites" do
    expect(user.can_edit_sites?).to be_true
  end

  it "can delete sites" do
    expect(user.can_delete_sites?).to be_true
  end

  it "can create comments" do
    expect(user.can_create_comments?).to be_true
  end

  it "can create health check templates" do
    expect(user.can_create_health_check_templates?).to be_true
  end

  it "can edit health check templates" do
    expect(user.can_edit_health_check_template?).to be_true
  end

  it "can import health checks" do
    expect(user.can_create_health_check_imports?).to be_true
  end

  it "can destroy imported health checks" do
    expect(user.can_delete_health_check_imports?).to be_true
  end

  it "can create deployments" do
    expect(user.can_create_deployments?).to be_true
  end

  it "can see deployment tokens" do
    expect(user.can_see_deployment_tokens?).to be_true
  end

  it "cannot to do anything else" do
    expect(user.can_do_whatever_he_wants?).to be_false
  end

  it "does not catch other methods" do
    expect { user.foobar }.to raise_error(NoMethodError)
  end
end
