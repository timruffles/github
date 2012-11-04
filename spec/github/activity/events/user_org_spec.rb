# encoding: utf-8

require 'spec_helper'

describe Github::Activity::Events, '#user_org' do
  let(:user)   { 'peter-murach' }
  let(:org) { 'github' }
  let(:request_path) { "/users/#{user}/events/orgs/#{org}" }
  let(:body) { fixture('events/events.json') }
  let(:status) { 200 }

  before {
    stub_get(request_path).to_return(:body => body, :status => status,
      :headers => {:content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for subject }

  context "resource found" do
    it { should respond_to :user_organization }

    it "should fail to get resource without orgname" do
      expect { subject.user_org user, nil }.to raise_error(ArgumentError)
    end

    it "should get the resources" do
      subject.user_org user, org
      a_get(request_path).should have_been_made
    end

    it "should return array of resources" do
      events = subject.user_org user, org
      events.should be_an Array
      events.should have(1).items
    end

    it "should be a mash type" do
      events = subject.user_org user, org
      events.first.should be_a Hashie::Mash
    end

    it "should get event information" do
      events = subject.user_org user, org
      events.first.type.should == 'Event'
    end

    it "should yield to a block" do
      subject.should_receive(:user_org).with(user, org).and_yield('web')
      subject.user_org(user, org) { |param| 'web' }
    end
  end

  context "resource not found" do
    let(:body) { '' }
    let(:status) { [404, "Not Found"] }

    it "should return 404 with a message 'Not Found'" do
      expect {
        subject.user_org user, org
      }.to raise_error(Github::Error::NotFound)
    end
  end
end # user_org