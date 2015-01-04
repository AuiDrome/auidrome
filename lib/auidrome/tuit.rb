require 'json'
module Auidrome
  class Tuit
      def self.store_these tuits
        File.open(TUITS_FILE,"w") do |f|
          f.write(tuits.to_json)
        end 
      end
    
      def self.current_stored_tuits
        if File.file?(TUITS_FILE)
          JSON.parse(File.read(TUITS_FILE))
        else
          {}
        end
      end

      def self.read_from_tuits_file auido
        {
          'created_at' => Tuit.current_stored_tuits[auido] || 'NOT FOUND!?!?',
          'auido' => auido,
          'identities' => [],
          'madrinos' => []
        }
      end

      def self.read_file(filepath)
        JSON.parse(File.read(filepath)) if File.exists?(filepath)
      end
  end
end
