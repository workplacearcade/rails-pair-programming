# frozen_string_literal: true

module IQMetrix
  module ResponseObject
    def self.included(base)
      base.class_eval do
        attr_accessor :payload

        def self.from_json(payload)
          new.tap do |object|
            payload_with_friendly_keys = payload.transform_keys! { |key| key.gsub(/\s|\W/, '').underscore.to_sym }

            object.payload = payload_with_friendly_keys
          end
        end
      end
    end

    def method_missing(method, *_args)
      return payload[method] if payload.keys.include?(method)

      super
    end

    def respond_to_missing?(method, include_private = false)
      payload.keys.include?(method) || super
    end
  end
end
