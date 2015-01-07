require 'json'
module Auidrome
  # A "human" is just a tuit with aditional attributes and a bit of magic :)
  class Human
    def initialize auido, reader
      @json = Human.read(auido, reader)
    end

    def attributes
      @json.keys
    end

    def method_missing(method, *args, &block)
      @json[method.to_s] || super
    end

    def hreferize method
      if @json[method] =~ /^http/
        @json[method]
      else
        "http://#{@json[method]}"
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

    def self.store human
      File.open(PUBLIC_TUITS_DIR + "/#{human['auido']}.json","w") do |f|
        f.write(human.to_json)
      end 
    end

    def self.read auido, reader = nil
      tuit_data = Tuit.read_from_tuits_file(auido)
      public_data = Tuit.read_file("#{PUBLIC_TUITS_DIR}/#{auido}.json")
      protected_data = if Auidrome::AccessLevel.can_read_protected?(reader, public_data)
        Tuit.read_file("#{PROTECTED_TUITS_DIR}/#{auido}.json")
      else
        {}
      end
      private_data = if Auidrome::AccessLevel.can_read_private?(reader, public_data)
        Tuit.read_file("#{PRIVATE_TUITS_DIR}/#{auido}.json")
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

  end
end
