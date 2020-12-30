# frozen_string_literal: true

module CanCan
  module PubSub
    extend ActiveSupport::Concern

    def subscribe(event, target = nil, &block)
      events[event] ||= []
      if target
        events[event] << target
      elsif block
        events[event] << block
      else
        raise ArgumentError
      end
      self
    end

    private

    def events
      @events ||= {}.with_indifferent_access
    end

    def publish(event)
      return if events[event].nil?

      events[event].each do |handler|
        if handler.is_a? Symbol
          send(handler, event, self)
        else
          handler.call(event, self)
        end
      end
    end

    included do
      methods = %i[can cannot can? cannot? authorize!]
      methods.each.each do |method|
        alias_method "#{method}_original", method
        define_method(method) do |*args, &block|
          publish("before_#{method}".to_sym)
          result = send("#{method}_original", *args, &block)
          publish("after_#{method}".to_sym)
          result
        end
      end
    end
  end
end