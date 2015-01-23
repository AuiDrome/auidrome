# Copyright 2015 The Cocktail Experience
require 'yaml'
module Auidrome
  class Config
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
    
    def drome_of_humans?
      @yaml['port_base'] < 10001
    end

    def self.base_domain
      @base_domain ||= File.open('config/base_domain').first.strip
    end

    def self.home_href
      @home_href ||= File.open('config/home_href').first.strip
    end

    def self.drome_mapping_for_property name
      drome_for_property(name) if property_names_with_associated_drome.include?(name)
    end

    def self.property_names_with_associated_drome
      unless @properties_drome
        @properties_drome = {}
        drome_property_mappings_file.each {|drome, property_names|
          property_names.split(',').map(&:to_sym).each {|prop|
            @properties_drome[prop] = drome
          }
        }
      end
      @properties_drome.keys
    end

    protected
    def self.drome_property_mappings_file
      @drome_property_mappings_file ||= YAML.load_file('config/drome_property_mappings.yml')
    end

    def self.drome_for_property(name)
      if @properties_drome[name].is_a? Auidrome::Config
        @properties_drome[name]
      else
        @properties_drome[name] = self.new("config/dromes/#{@properties_drome[name]}.yml")
      end
    end
  end
end
