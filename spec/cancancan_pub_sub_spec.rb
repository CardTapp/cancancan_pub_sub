# frozen_string_literal: true

require "cancan/pub_sub"

RSpec.describe CanCan::PubSub do
  class self::Ability
    include CanCan::Ability
    include CanCan::PubSub
  end

  RSpec.shared_examples("runs callbacks") do |type|
    it "runs callbacks for #{type}" do
      ability = self.class::Ability.new
      after = ->(evt, obj) {}
      before = ->(evt, obj) {}
      ability.subscribe("after_#{type}", &after)
      ability.subscribe("before_#{type}", &before)

      expect(before).to receive(:call).with(:"before_#{type}", ability).ordered
      expect(after).to receive(:call).with(:"after_#{type}", ability).ordered

      ability.send type, :something, :otherthing
    end
  end

  it_behaves_like "runs callbacks", :can
  it_behaves_like "runs callbacks", :cannot
  it_behaves_like "runs callbacks", :can?
  it_behaves_like "runs callbacks", :cannot?

  it "runs callbacks for authorize! when authorized" do
    ability = self.class::Ability.new
    after = ->(evt, obj) {}
    before = ->(evt, obj) {}
    ability.subscribe("after_authorize!", &after)
    ability.subscribe("before_authorize!", &before)
    ability.can :something, :otherthing

    expect(before).to receive(:call).with(:"before_authorize!", ability).ordered
    expect(after).to receive(:call).with(:"after_authorize!", ability).ordered

    ability.authorize! :something, :otherthing
  end

  it "runs callbacks for authorize! when unauthorized" do
    ability = self.class::Ability.new
    after = ->(evt, obj) {}
    before = ->(evt, obj) {}
    ability.subscribe("after_authorize!", &after)
    ability.subscribe("before_authorize!", &before)

    expect(before).to receive(:call).with(:"before_authorize!", ability).ordered
    expect(after).not_to receive(:call).with(:"after_authorize!", ability).ordered

    expect { ability.authorize!(:something, :otherthing) }.to raise_error(CanCan::AccessDenied)
  end
end
