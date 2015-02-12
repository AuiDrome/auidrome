# Copyright 2015 The Cocktail Experience
require 'yaml'
module Auidrome
  class Config
    @@dromes, @@properties_drome, @@values_drome = {}, {}, {}

    def initialize cfg_file=nil
      cfg_file ||= "config/dromes/auidrome.yml"
      cfg_file = "config/dromes/#{cfg_file.downcase}.yml" unless cfg_file =~ /^config.+yml$/
      @yaml = YAML.load_file(cfg_file)
      @dromename = File.basename(cfg_file, '.yml').to_sym
    end

    def method_missing(method, *args, &block)
      if self.class.respond_to?(method)
        self.class.send method
      else
        @yaml[method.to_s] || super
      end
    end

    def dromename
      @dromename
    end

    def self.drome dromename
      load_drome dromename.to_sym
    end

    def self.pedalodrome
      load_drome :pedalodrome
    end

    def drome_of_humans?
      @yaml['port_base'] < 10001
    end

    def pretty_json?
      File.exists? 'config/generate_pretty_json'
    end

    def domain_and_port
      App.settings.base_domain + ":" + @yaml['port_base'].to_s
    end

    def url
      "http://#{domain_and_port}"
    end

    def self.drome_mapping_for name, value
      if property_names_with_associated_drome.include?(name)
        # "value" can refine the drome selection
        drome_for_value(value.to_sym) || drome_for_property(name)
      end
    end

    def self.properties_with_drome
      property_names_with_associated_drome.each do |property|
        drome_for_property property
      end
      @@properties_drome
    end

    def self.property_names_with_associated_drome
      if @@properties_drome.empty?
        drome_property_mappings_file.each {|drome, property_names|
          property_names.split(',').map(&:to_sym).each {|prop|
            @@properties_drome[prop] = drome
          }
        }
      end
      @@properties_drome.keys
    end

    def self.drome_for_property(name)
      if @@properties_drome[name].is_a? Auidrome::Config
        @@properties_drome[name]
      else
        @@properties_drome[name] = load_drome(@@properties_drome[name])
      end
    end

    protected
    def self.drome_property_mappings_file
      @drome_property_mappings_file ||= YAML.load_file('config/drome_property_mappings.yml')
    end

    def self.drome_for_value(value)
      if @@values_drome[value].is_a? Auidrome::Config
        @@values_drome[value]
      elsif drome = People.drome_for(value.to_sym)
        @@values_drome[value] = load_drome(drome)
      end
    end

    def self.load_drome dromename
      @@dromes[dromename.to_sym] ||= new("config/dromes/#{dromename}.yml")
    end
  end
end
