require 'json'
module Auidrome
  # A "human" is just a tuit with aditional properties and a bit of magic :)
  class Human
    def initialize auido, reader = nil
      @hash = Human.read_json(auido, reader)
      @hash['identities'] ||= []
      @hash['madrinos'] ||= []
    end

    def hash
      @hash
    end

    def properties
      @hash.keys
    end

    def values
      @hash.values
    end

    def method_missing(method, *args, &block)
      @hash[method.to_s] || super
    end

    def core_properties
      Auidrome::CORE_PROPERTIES # no more, no less, by now...
    end

    def self.linkable_property? property, value
      Auidrome::HREF_PROPERTIES.include?(property) or
        Auidrome::Config.property_names_with_associated_drome.include?(property.to_sym) or
          value =~ /^https?:\/\//
    end

    def self.protocol_for property
      Auidrome::PROTOCOLS[property.downcase] || 'http://'
    end

    def hrefable_property? property, value
      Auidrome::Human.linkable_property? property, value
    end

    def href_for name, value
      if value =~ /^https?:/
        value
      elsif template = Auidrome::PROPERTY_VALUE_TEMPLATES[name.downcase.to_sym]
        template.gsub('{{value}}', value)
      elsif drome = Auidrome::Config.drome_mapping_for_property(name.downcase)
        "#{Auidrome::Human.protocol_for(name)}#{drome.base_domain}:#{drome.port_base}/tuits/#{value}"
      else
        "#{Auidrome::Human.protocol_for(name)}#{value}"
      end
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
      File.open(PUBLIC_TUITS_DIR + "/#{@hash['auido']}.json","w") do |f|
        f.write(hash.to_json)
      end 
    end

    def self.store_json hash
      File.open(PUBLIC_TUITS_DIR + "/#{hash['auido']}.json","w") do |f|
        f.write(hash.to_json)
      end 
    end

    def self.read_json auido, reader = nil
      tuit_data = Tuit.read_from_index_file(auido)
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

      private_data.merge(
        protected_data.merge(
          public_data.merge(
            tuit_data
          )
        )
      )
    end

    def add_value! property, value
      if @hash[property] and @hash[property].is_a?(Array)
         @hash[property] << value
      elsif @hash[property]
         @hash[property] = [value]
      else
         @hash[property] = value
      end
      save_json!
    end

    def add_identity! user
      @hash['identities'] << user unless @hash['identities'].include? user
      save_json!
    end

    def add_madrino! user
      @hash['madrinos'] << user unless @hash['madrinos'].include? user
      save_json!
    end

    def self.add_madrino! auido, user
      human = Auidrome::Human.new(auido, user)
      human.hash['madrinos'] << user unless human.madrinos.include? user
      Auidrome::Human.store_json human.hash
    end
  end
end
