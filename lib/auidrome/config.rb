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
      # TODO: this method based on a config file (this code is provissional just to see it working)
      if %w{doc talk spec}.include? name.downcase     
        self.new('config/dromes/docudrome.yml')
      elsif name.downcase == "tel."
        nil
      else
        self.new('config/dromes/lovedrome.yml')
      end
    end
  end
end
