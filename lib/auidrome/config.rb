# Copyright 2015 The Cocktail Experience
require 'yaml'
module Auidrome
  class Config
    @@pedalodrome = nil
    @@properties_drome, @@values_drome = {}, {}

    def initialize cfg_file=nil
      cfg_file ||= "config/dromes/auidrome.yml"
      cfg_file = "config/dromes/#{cfg_file.downcase}.yml" unless cfg_file =~ /^config.+yml$/
      @yaml = YAML.load_file(cfg_file)
    end

    def method_missing(method, *args, &block)
      if self.class.respond_to?(method)
        self.class.send method
      else
        @yaml[method.to_s] || super
      end
    end
    
    def self.pedalodrome
      @@pedalodrome ||= new_drome(:pedalodrome)
    end

    def drome_of_humans?
      @yaml['port_base'] < 10001
    end

    def domain_and_port
      Auidrome::Config.base_domain + ":" + @yaml['port_base'].to_s
    end

    def url
      "http://#{domain_and_port}"
    end

    def self.base_domain
      @@base_domain ||= File.open('config/base_domain').first.strip
    end

    def self.home_href
      @@home_href ||= File.open('config/home_href').first.strip
    end

    def self.drome_mapping_for name, value
      if property_names_with_associated_drome.include?(name)
        # "value" can refine the drome selection
        drome_for_value(value.to_sym) || drome_for_property(name)
      end
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

    protected
    def self.drome_property_mappings_file
      @drome_property_mappings_file ||= YAML.load_file('config/drome_property_mappings.yml')
    end

    def self.drome_for_property(name)
      if @@properties_drome[name].is_a? Auidrome::Config
        @@properties_drome[name]
      else
        @@properties_drome[name] = new_drome(@@properties_drome[name])
      end
    end

    def self.drome_for_value(value)
      if @@values_drome[value].is_a? Auidrome::Config
        @@values_drome[value]
      elsif drome = People.drome_for(value.to_sym)
        @@values_drome[value] = new_drome(drome)
      end
    end

    def self.new_drome dromename
      new("config/dromes/#{dromename}.yml")
    end
  end
end
