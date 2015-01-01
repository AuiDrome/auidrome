require 'json'
module Auidrome
  # A "human" is just a tuit with aditional attributes and a bit of magic :)
  class Human
    def initialize auido
      @json = Human.read(auido)
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
      File.open(TUITS_DIR + "/#{human['auido']}.json","w") do |f|
        f.write(human.to_json)
      end 
    end

    def self.read auido
      if File.exists?("#{TUITS_DIR}/#{auido}.json")
        JSON.parse File.read("#{TUITS_DIR}/#{auido}.json")
      else
        Tuit.read_from_tuits_file auido
      end
    end

  end
end
