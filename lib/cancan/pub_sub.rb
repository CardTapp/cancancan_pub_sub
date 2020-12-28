# frozen_string_literal: true

module CanCan
  module PubSub
    extend ActiveSupport::Concern

    def subscribe(event, &block)
      ActiveSupport::Notifications.subscribe(event.to_sym, &block)
      self
    end

    private

    def publish(event)
      ActiveSupport::Notifications.publish(event, self)
    end

    included do
      methods = %i[can cannot can? cannot? authorize!]
      methods.each.each do |method|
        alias_method "#{method}_original", method
        define_method(method) do |*args|
          publish("before_#{method}".to_sym)
          result = send("#{method}_original", *args)
          publish("after_#{method}".to_sym)
          result
        end
      end
    end
  end
end