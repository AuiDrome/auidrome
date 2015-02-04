# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  class Drome
    def initialize app
      @app = app
      @hash = {
        identity: [],
        madrino: []
      }
    end

    def hash
      @hash
    end

    def conf
      @app.config
    end

    def properties
      @hash.keys
    end

    def values
      @hash.values
    end

    def method_missing(method, *args, &block)
      @hash[method.to_sym] || super
    end

    def core_properties
      Auidrome::CORE_PROPERTIES # no more, no less, by now...
    end

    def self.linkable_property? property, value
      Auidrome::HREF_PROPERTIES.include?(property) or
        Auidrome::PROPERTY_VALUE_TEMPLATES.include?(property.to_sym) or
          Auidrome::Config.property_names_with_associated_drome.include?(property.to_sym) or
            value =~ /^https?:\/\//i
    end

    def self.protocol_for property
      Auidrome::PROTOCOLS[property.downcase] || 'http://'
    end

    def hrefable_property? property, value
      value =~ /^https?:/i or
        Drome.linkable_property? property.downcase, value
    end

    def href_for name, value
      name_sym = name.downcase.to_sym
      if value =~ /^https?:/i
        value
      elsif template = Auidrome::PROPERTY_VALUE_TEMPLATES[name_sym]
        template.gsub('{{value}}', value)
      elsif drome = Auidrome::Config.drome_mapping_for(name_sym, value)
        "#{Drome.protocol_for(name)}#{drome.domain_and_port}/tuits/#{value}"
      else
        "#{Drome.protocol_for(name)}#{value}"
      end
    end

    def image_src
      if @hash[:auido] and image_file?
        @image_file
      else
        "/images/frijolito.png"
      end
    end

    def image_href
      if better_image?
        "/tuits/better/#{@hash[:auido]}"
      else
        "/tuits/#{@hash[:auido]}"
      end
    end

    def better_image?
      !(image_of_quality(image_quality+1)).nil?
    end

    def enumerable(property)
      val = self.send(property)
      if val.is_a? Enumerable
        val
      else
        [val]
      end
    end

    def save_json!
      @app.save_json! basic_jsonld_for(@hash[:auido]).merge(@hash)
    end

    def basic_data_for auido
      Tuit.read_from_index_file(auido).merge @hash
    end

    def basic_jsonld_for auido
      {
        '@context' => conf.url + "/json-context.json",
        '@id' => conf.url + "/tuits/#{auido}"
      }.merge(basic_data_for(auido))
    end

    def image_quality
      @quality ||= 0
    end   

    def load_json auido, reader = nil, quality = 0
      @quality = quality # Currently only for image quality ("better" subdir levels)
      public_data = Tuit.read_json("#{PUBLIC_TUITS_DIR}/#{auido}.json")
      protected_data = if Auidrome::AccessLevel.can_read_protected?(reader, public_data)
        Tuit.read_json("#{PROTECTED_TUITS_DIR}/#{auido}.json")
      else
        {}
      end
      private_data = if Auidrome::AccessLevel.can_read_private?(reader, public_data)
        Tuit.read_json("#{PRIVATE_TUITS_DIR}/#{auido}.json")
      else
        {}
      end
      @hash = basic_data_for(auido).merge(public_data.merge(protected_data.merge(private_data)))
      self
    end

    def add_value! property, value
      if @hash[property] and @hash[property].is_a?(Array)
         @hash[property] << value
      elsif @hash[property]
         @hash[property] = [@hash[property], value]
      else
         @hash[property] = value
      end
      save_json!
    end

    def add_identity! user
      @hash[:identity] << user unless @hash[:identity].include? user
      save_json!
    end

    def add_madrino! user
      @hash[:madrino] << user unless @hash[:madrino].include? user
      save_json!
    end


    private
    def image_file?
      @image_file = image_of_quality(image_quality) unless @image_file
      !@image_file.nil?
    end

    def image_of_quality quality
      prefix = quality > 0 ? "#{(['better']*quality).join('/')}/" : ""
      basepath = "/images/#{prefix}" + @hash[:auido] 
      %w{jpg png gif jpeg}.each do |extension|
        filepath = "#{basepath}.#{extension}"
        return filepath if File.exists?("public" + filepath)
      end
      return nil
    end

  end
end
