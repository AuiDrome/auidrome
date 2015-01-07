require 'json'
module Auidrome
  # A "human" is just a tuit with aditional attributes and a bit of magic :)
  class Human
    def initialize auido, reader = nil
      @hash = Human.read_json(auido, reader)
      @hash['identities'] ||= []
      @hash['madrinos'] ||= []
    end

    def hash
      @hash
    end

    def attributes
      @hash.keys
    end

    def values
      @hash.values
    end

    def method_missing(method, *args, &block)
      @hash[method.to_s] || super
    end

    def hreferize method
      if @hash[method] =~ /^http/
        @hash[method]
      else
        "http://#{@hash[method]}"
      end
    end

    def enumerable(attribute)
      val = self.send(attribute)
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
