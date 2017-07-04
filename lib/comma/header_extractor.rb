# -*- coding: utf-8 -*-
require 'comma/extractor'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'

module Comma
  class HeaderExtractor < Extractor

    class_attribute :value_humanizer

    DEFAULT_VALUE_HUMANIZER = lambda do |value, model_class|
      value.is_a?(String) ? value : value.to_s.humanize
    end
    self.value_humanizer = DEFAULT_VALUE_HUMANIZER

    def method_missing(sym, *args, &block)
      model_class = @instance.class
      @results << header_string(sym) if args.blank?
      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            @results << ((v.is_a? String) ? v : header_string(v))
          end
        when Symbol
          @results << header_string(arg)
        when String
          @results << self.value_humanizer.call(arg, model_class)
        else
          raise "Unknown header symbol #{arg.inspect}"
        end
      end
    end

    def __static_column__(header = '', &block)
      @results << header
    end

    def header_string(attribute)
      @instance.class.human_attribute_name(attribute)
    end
    private

    def get_association_class(model_class, association)
      if model_class.respond_to?(:reflect_on_association)
        association = model_class.reflect_on_association(association)
        association.klass rescue nil
      end
    end
  end
end
