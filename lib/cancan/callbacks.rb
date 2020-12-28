# frozen_string_literal: true

module CanCan
  module Callbacks
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks

      methods = %i[can cannot can? cannot? authorize!]
      methods.each.each do |method|
        callback_name = method.to_s.sub(/[?!]/, "_check")
        define_callbacks(callback_name)
        alias_method "#{method}_original", method
        define_method(method) do |*args|
          run_callbacks callback_name do
            send("#{method}_original", *args)
          end
        end
      end
    end
  end
end