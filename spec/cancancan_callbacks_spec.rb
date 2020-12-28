# frozen_string_literal: true

require "cancan/callbacks"

RSpec.describe CanCan::Callbacks do
  class self::Ability
    include CanCan::Ability
    include CanCan::Callbacks

    def after
      to_s
    end

    def before
      to_s
    end
  end

  RSpec.shared_examples("runs callbacks") do |type|
    callback_name = type.to_s.sub(/[?!]/, "_check")
    after do
      self.class::Ability.reset_callbacks(callback_name)
    end

    it "runs callbacks for #{type}" do
      self.class::Ability.set_callback callback_name, :after, :after
      self.class::Ability.set_callback callback_name, :before, :before

      ability = self.class::Ability.new
      expect(ability).to receive(:before)
      expect(ability).to receive(:after)
      ability.send type, :something, :otherthing
    end
  end

  it_behaves_like "runs callbacks", :can
  it_behaves_like "runs callbacks", :cannot
  it_behaves_like "runs callbacks", :can?
  it_behaves_like "runs callbacks", :cannot?

  it "runs callbacks for authorize! when authorized" do
    self.class::Ability.set_callback :authorize_check, :after, :after
    self.class::Ability.set_callback :authorize_check, :before, :before

    ability = self.class::Ability.new
    ability.can :something, :otherthing
    expect(ability).to receive(:before)
    expect(ability).to receive(:after)
    ability.authorize! :something, :otherthing
  end

  it "runs callbacks for authorize! when unauthorized" do
    self.class::Ability.set_callback :authorize_check, :after, :after
    self.class::Ability.set_callback :authorize_check, :before, :before

    ability = self.class::Ability.new
    expect(ability).to receive(:before)
    expect(ability).not_to receive(:after)

    expect { ability.authorize! :something, :otherthing }.to raise_error CanCan::AccessDenied
  end
end
